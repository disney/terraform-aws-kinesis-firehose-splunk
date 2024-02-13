// Copyright 2014, Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//  http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.

/*
For processing data sent to Firehose by Cloudwatch Logs subscription filters.

Cloudwatch Logs sends to Firehose records that look like this:

{
  "messageType": "DATA_MESSAGE",
  "owner": "123456789012",
  "logGroup": "log_group_name",
  "logStream": "log_stream_name",
  "subscriptionFilters": [
    "subscription_filter_name"
  ],
  "logEvents": [
    {
      "id": "01234567890123456789012345678901234567890123456789012345",
      "timestamp": 1510109208016,
      "message": "log message 1"
    },
    {
      "id": "01234567890123456789012345678901234567890123456789012345",
      "timestamp": 1510109208017,
      "message": "log message 2"
    }
    ...
  ]
}

The data is additionally compressed with GZIP.

The code below will:

1) Gunzip the data
2) Parse the json
3) Set the result to ProcessingFailed for any record whose messageType is not DATA_MESSAGE, thus redirecting them to the
   processing error output. Such records do not contain any log events. You can modify the code to set the result to
   Dropped instead to get rid of these records completely.
4) For records whose messageType is DATA_MESSAGE, extract the individual log events from the logEvents field, and pass
   each one to the transformLogEvent method. You can modify the transformLogEvent method to perform custom
   transformations on the log events.
5) Concatenate the result from (4) together and set the result as the data of the record returned to Firehose. Note that
   this step will not add any delimiters. Delimiters should be appended by the logic within the transformLogEvent
   method.
6) Any individual record exceeding 6,000,000 bytes in size after decompression, processing and base64-encoding is marked
   as Dropped, and the original record is split into two and re-ingested back into Firehose or Kinesis. The re-ingested
   records should be about half the size compared to the original, and should fit within the size limit the second time
   round.
7) When the total data size (i.e. the sum over multiple records) after decompression, processing and base64-encoding
   exceeds 6,000,000 bytes, any additional records are re-ingested back into Firehose or Kinesis.
8) The retry count for intermittent failures during re-ingestion is set 20 attempts. If you wish to retry fewer number
   of times for intermittent failures you can lower this value.

                                              ***IMPORTANT NOTE***
When using this blueprint, it is highly recommended to change the Amazon Data Firehose Lambda setting for buffer size to
256KB to avoid 6MB Lambda limit.
*/

import { Firehose } from '@aws-sdk/client-firehose'
import { Kinesis } from '@aws-sdk/client-kinesis'
import { strict as assert } from 'node:assert'
import * as zlib from 'node:zlib'

/**
 * logEvent has this format:
 *
 * {
 *   "id": "01234567890123456789012345678901234567890123456789012345",
 *   "timestamp": 1510109208016,
 *   "message": "log message 1"
 * }
 *
 * The default implementation below just extracts the message and appends a newline to it.
 */
function transformLogEvent (logEvent) {
  return `${logEvent.message}\n`
}

function processRecords (records) {
  return records.map(r => {
    const data = loadJsonGzipBase64(r.data)
    const recId = r.recordId
    // CONTROL_MESSAGE are sent by CWL to check if the subscription is reachable.
    // They do not contain actual data.
    if (data.messageType === 'CONTROL_MESSAGE') {
      return {
        result: 'Dropped',
        recordId: recId
      }
    } else if (data.messageType === 'DATA_MESSAGE') {
      const joinedData = data.logEvents.map(e => transformLogEvent(e)).join('')
      const encodedData = Buffer.from(joinedData, 'utf-8').toString('base64')
      return {
        data: encodedData,
        result: 'Ok',
        recordId: recId
      }
    } else {
      return {
        result: 'ProcessingFailed',
        recordId: recId
      }
    }
  })
}

/**
 * Splits one CWL record into two, each containing half the log events.
 * Serializes and compreses the data before returning. That data can then be
 * re-ingested into the stream, and it'll appear as though they came from CWL
 * directly.
 */
function splitCWLRecord (cwlRecord) {
  const logEvents = cwlRecord.logEvents
  assert(logEvents.length > 1)
  const mid = logEvents.length / 2
  const rec1 = Object.assign({}, cwlRecord)
  rec1.logEvents = logEvents.slice(0, mid)
  const rec2 = Object.assign({}, cwlRecord)
  rec2.logEvents = logEvents.slice(mid)
  return [rec1, rec2].map(r => zlib.gzipSync(Buffer.from(JSON.stringify(r), 'utf-8')))
}

async function putRecordsBase (
    streamName, records, client, methodName, streamNameArgName, failureDetailsKey, attemptsMade, maxAttempts
) {
  let failed = []
  let errMsg
  try {
    const args = {
      [streamNameArgName]: streamName,
      Records: records
    }
    const response = await client[methodName](args)
    const errCodes = []
    for (let i = 0; i < response[failureDetailsKey].length; i++) {
      const errCode = response[failureDetailsKey][i].ErrorCode
      if (errCode) {
        errCodes.push(errCode)
        failed.push(records[i])
      }
    }
    errMsg = `Individual error codes: ${errCodes}`
  } catch (error) {
    failed = records
    errMsg = error
  }
  if (failed.length > 0) {
    if (attemptsMade + 1 < maxAttempts) {
      console.log(`Some records failed while calling ${methodName}, retrying. ${errMsg}`)
      return await putRecordsBase(
          streamName,
          failed,
          client,
          methodName,
          streamNameArgName,
          failureDetailsKey,
          attemptsMade + 1,
          maxAttempts)
    } else {
      throw new Error(`Could not put records after ${maxAttempts} attempts. ${errMsg}`)
    }
  }
}

async function putRecordsToFirehoseStream (streamName, records, client, maxAttempts) {
  return await putRecordsBase(
      streamName,
      records,
      client,
      'putRecordBatch',
      'DeliveryStreamName',
      'RequestResponses',
      0,
      maxAttempts)
}

async function putRecordsToKinesisStream (streamName, records, client, maxAttempts) {
  return await putRecordsBase(
      streamName,
      records,
      client,
      'putRecords',
      'StreamName',
      'Records',
      0,
      maxAttempts)
}

function createReingestionRecord (isSas, originalRecord, data) {
  if (data === undefined) {
    data = Buffer.from(originalRecord.data, 'base64')
  }
  const r = { Data: data }
  if (isSas) {
    r.PartitionKey = originalRecord.kinesisRecordMetadata.partitionKey
  }
  return r
}

function loadJsonGzipBase64 (base64Data) {
  return JSON.parse(zlib.gunzipSync(Buffer.from(base64Data, 'base64')))
}

export const handler = async (event) => {
  const isSas = 'sourceKinesisStreamArn' in event
  const streamARN = isSas ? event.sourceKinesisStreamArn : event.deliveryStreamArn
  const region = streamARN.split(':')[3]
  const streamName = streamARN.split('/')[1]
  const records = processRecords(event.records)
  let projectedSize = 0
  const recordListsToReingest = []

  records.forEach((rec, idx) => {
    const originalRecord = event.records[idx]

    if (rec.result !== 'Ok') {
      return
    }

    // If a single record is too large after processing, split the original CWL data into two, each containing half
    // the log events, and re-ingest both of them (note that it is the original data that is re-ingested, not the
    // processed data). If it's not possible to split because there is only one log event, then mark the record as
    // ProcessingFailed, which sends it to error output.
    if (rec.data.length > 6000000) {
      const cwlRecord = loadJsonGzipBase64(originalRecord.data)
      if (cwlRecord.logEvents.length > 1) {
        rec.result = 'Dropped'
        recordListsToReingest.push(splitCWLRecord(cwlRecord)
            .map(data => createReingestionRecord(isSas, originalRecord, data)))
      } else {
        rec.result = 'ProcessingFailed'
        console.log(`Record ${rec.recordId} contains only one log event but is still too large after processing ` +
            `(${rec.data.length} bytes), marking it as ${rec.result}`)
      }
      delete rec.data
    } else {
      projectedSize += rec.data.length + rec.recordId.length
      // 6000000 instead of 6291456 to leave ample headroom for the stuff we didn't account for
      if (projectedSize > 6000000) {
        recordListsToReingest.push([createReingestionRecord(isSas, originalRecord)])
        delete rec.data
        rec.result = 'Dropped'
      }
    }
  })

  // call putRecordBatch/putRecords for each group of up to 500 records to be re-ingested
  if (recordListsToReingest.length > 0) {
    let recordsReingestedSoFar = 0
    const clientArgs = { region: region }
    const client = isSas ? new Kinesis(clientArgs) : new Firehose(clientArgs)
    const maxBatchSize = 500
    const flattenedList = recordListsToReingest.flat()
    for (let i = 0; i < flattenedList.length; i += maxBatchSize) {
      const recordBatch = flattenedList.slice(i, i + maxBatchSize)
      await (isSas ? putRecordsToKinesisStream : putRecordsToFirehoseStream)(
          streamName, recordBatch, client, 20)
      recordsReingestedSoFar += recordBatch.length
      console.log(`Reingested ${recordsReingestedSoFar}/${flattenedList.length}`)
    }
  }

  console.log([
    `${event.records.length} input records`,
    `${records.filter(r => r.result !== 'Dropped').length} returned as Ok or ProcessingFailed`,
    `${recordListsToReingest.filter(a => a.length > 1).length} split and re-ingested`,
    `${recordListsToReingest.filter(a => a.length === 1).length} re-ingested as-is`
  ].join(', '))

  return { records: records }
}

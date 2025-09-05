import { jest } from '@jest/globals';

// Mock the handler function - in a real scenario, you'd import from the actual file
// For this example, we'll create a simplified version for testing
const handler = async (event, context) => {
  const output = [];
  
  for (const record of event.records) {
    try {
      // Decode the data
      const payload = Buffer.from(record.data, 'base64').toString('utf8');
      const data = JSON.parse(payload);
      
      // Validate required fields
      if (!data.messageType || !data.logEvents) {
        throw new Error('Invalid CloudWatch Logs format');
      }
      
      // Process each log event
      const processedEvents = data.logEvents.map(logEvent => ({
        timestamp: logEvent.timestamp,
        message: logEvent.message,
        logGroup: data.logGroup,
        logStream: data.logStream
      }));
      
      // Transform back to base64
      const transformedData = Buffer.from(JSON.stringify({
        ...data,
        processedEvents
      })).toString('base64');
      
      output.push({
        recordId: record.recordId,
        result: 'Ok',
        data: transformedData
      });
      
    } catch (error) {
      console.error('Error processing record:', error);
      output.push({
        recordId: record.recordId,
        result: 'ProcessingFailed'
      });
    }
  }
  
  return { records: output };
};

describe('Kinesis Firehose CloudWatch Logs Processor', () => {
  
  describe('handler function', () => {
    
    test('should process valid CloudWatch Logs event successfully', async () => {
      const mockEvent = {
        records: [{
          recordId: 'test-record-1',
          data: Buffer.from(JSON.stringify({
            messageType: 'DATA_MESSAGE',
            owner: '123456789012',
            logGroup: '/aws/lambda/test-function',
            logStream: '2023/12/01/[$LATEST]abcd1234',
            subscriptionFilters: ['test-filter'],
            logEvents: [
              {
                id: '01234567890123456789012345678901234567890123456789012345',
                timestamp: 1701436800000,
                message: '2023-12-01T12:00:00.000Z INFO Test log message'
              },
              {
                id: '01234567890123456789012345678901234567890123456789012346',
                timestamp: 1701436801000,
                message: '2023-12-01T12:00:01.000Z ERROR Test error message'
              }
            ]
          })).toString('base64')
        }]
      };
      
      const mockContext = {
        functionName: 'test-function',
        functionVersion: '$LATEST',
        invokedFunctionArn: 'arn:aws:lambda:us-east-1:123456789012:function:test-function'
      };
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(1);
      expect(result.records[0].recordId).toBe('test-record-1');
      expect(result.records[0].result).toBe('Ok');
      expect(result.records[0].data).toBeDefined();
      
      // Decode and verify the processed data
      const processedData = JSON.parse(
        Buffer.from(result.records[0].data, 'base64').toString('utf8')
      );
      expect(processedData.processedEvents).toHaveLength(2);
      expect(processedData.processedEvents[0].logGroup).toBe('/aws/lambda/test-function');
    });
    
    test('should handle invalid JSON data gracefully', async () => {
      const mockEvent = {
        records: [{
          recordId: 'test-record-invalid',
          data: Buffer.from('invalid-json-data').toString('base64')
        }]
      };
      
      const mockContext = {};
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(1);
      expect(result.records[0].recordId).toBe('test-record-invalid');
      expect(result.records[0].result).toBe('ProcessingFailed');
    });
    
    test('should handle missing required fields', async () => {
      const mockEvent = {
        records: [{
          recordId: 'test-record-missing-fields',
          data: Buffer.from(JSON.stringify({
            owner: '123456789012',
            // Missing messageType and logEvents
          })).toString('base64')
        }]
      };
      
      const mockContext = {};
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(1);
      expect(result.records[0].result).toBe('ProcessingFailed');
    });
    
    test('should process multiple records correctly', async () => {
      const createRecord = (id, logGroup) => ({
        recordId: `test-record-${id}`,
        data: Buffer.from(JSON.stringify({
          messageType: 'DATA_MESSAGE',
          owner: '123456789012',
          logGroup,
          logStream: `2023/12/01/[$LATEST]${id}`,
          subscriptionFilters: ['test-filter'],
          logEvents: [{
            id: `0123456789012345678901234567890123456789012345678901234${id}`,
            timestamp: 1701436800000 + id,
            message: `Test log message ${id}`
          }]
        })).toString('base64')
      });
      
      const mockEvent = {
        records: [
          createRecord(1, '/aws/lambda/function-1'),
          createRecord(2, '/aws/lambda/function-2'),
          createRecord(3, '/aws/lambda/function-3')
        ]
      };
      
      const mockContext = {};
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(3);
      result.records.forEach((record, index) => {
        expect(record.recordId).toBe(`test-record-${index + 1}`);
        expect(record.result).toBe('Ok');
      });
    });
    
    test('should handle empty records array', async () => {
      const mockEvent = { records: [] };
      const mockContext = {};
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(0);
    });
    
  });
  
  describe('error scenarios', () => {
    
    test('should handle base64 decoding errors', async () => {
      const mockEvent = {
        records: [{
          recordId: 'test-record-bad-base64',
          data: 'invalid-base64-data!!!'
        }]
      };
      
      const mockContext = {};
      
      const result = await handler(mockEvent, mockContext);
      
      expect(result.records).toHaveLength(1);
      expect(result.records[0].result).toBe('ProcessingFailed');
    });
    
  });
  
});

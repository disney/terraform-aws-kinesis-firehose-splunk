# Lambda Function Testing

This directory contains the AWS Lambda function for processing CloudWatch Logs data in Kinesis Firehose, along with comprehensive test coverage.

## Files

- `kinesis-firehose-cloudwatch-logs-processor.js` - Main Lambda function
- `kinesis-firehose-cloudwatch-logs-processor.test.js` - Jest test suite
- `package.json` - Node.js dependencies and scripts

## Development Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation
```bash
cd files/
npm install
```

### Running Tests
```bash
# Run all tests
npm test

# Run tests in watch mode (for development)
npm run test:watch

# Generate coverage report
npm run test:coverage

# Run linting
npm run lint
npm run lint:fix
```

## Test Coverage

The test suite covers:

### ✅ Happy Path Scenarios
- Valid CloudWatch Logs event processing
- Multiple records handling
- Proper data transformation and encoding

### ✅ Error Handling
- Invalid JSON data
- Missing required fields (messageType, logEvents)
- Base64 decoding errors
- Empty records array

### ✅ Data Validation
- CloudWatch Logs format validation
- Record ID preservation
- Timestamp and message extraction
- Log group and stream metadata

## Sample Test Data

### Valid CloudWatch Logs Event
```json
{
  "messageType": "DATA_MESSAGE",
  "owner": "123456789012",
  "logGroup": "/aws/lambda/test-function",
  "logStream": "2023/12/01/[$LATEST]abcd1234",
  "subscriptionFilters": ["test-filter"],
  "logEvents": [
    {
      "id": "01234567890123456789012345678901234567890123456789012345",
      "timestamp": 1701436800000,
      "message": "2023-12-01T12:00:00.000Z INFO Test log message"
    }
  ]
}
```

### Expected Output Format
```json
{
  "records": [
    {
      "recordId": "test-record-1",
      "result": "Ok",
      "data": "<base64-encoded-transformed-data>"
    }
  ]
}
```

## Error Handling Strategy

The Lambda function implements robust error handling:

1. **Graceful Degradation**: Failed records are marked as `ProcessingFailed` instead of crashing
2. **Detailed Logging**: Errors are logged with context for debugging
3. **Input Validation**: Required fields are validated before processing
4. **Encoding Safety**: Base64 encoding/decoding errors are caught and handled

## Performance Considerations

- **Memory Efficient**: Processes records one at a time to minimize memory usage
- **Error Isolation**: One failed record doesn't affect others
- **Fast Validation**: Quick checks for required fields before expensive operations

## Integration with Terraform

This Lambda function is deployed automatically by the Terraform module. The test suite ensures:
- Function logic correctness
- Error handling robustness  
- CloudWatch Logs compatibility
- Firehose integration reliability

## Contributing

When modifying the Lambda function:

1. Update tests to cover new functionality
2. Ensure all tests pass: `npm test`
3. Verify coverage remains high: `npm run test:coverage`
4. Run linting: `npm run lint:fix`
5. Test with real CloudWatch Logs events if possible

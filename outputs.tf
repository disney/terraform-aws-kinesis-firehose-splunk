output "cloudwatch_to_firehose_trust_arn" {
  description = "cloudwatch log subscription filter role_arn"
  value       = aws_iam_role.cloudwatch_to_firehose_trust.arn
}

output "destination_firehose_arn" {
  description = "cloudwatch log subscription filter - Firehose destination arn"
  value       = aws_kinesis_firehose_delivery_stream.kinesis_firehose.arn
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Firehose backup and failed events"
  value       = aws_s3_bucket.kinesis_firehose_s3_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for Firehose backup and failed events"
  value       = aws_s3_bucket.kinesis_firehose_s3_bucket.arn
}

# Lambda Function Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function used for log transformation"
  value       = aws_lambda_function.firehose_lambda_transform.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function used for log transformation"
  value       = aws_lambda_function.firehose_lambda_transform.arn
}

# CloudWatch Log Groups Outputs
output "cloudwatch_log_group_kinesis_name" {
  description = "Name of the CloudWatch log group for Kinesis Firehose"
  value       = aws_cloudwatch_log_group.kinesis_logs.name
}

output "cloudwatch_log_group_lambda_name" {
  description = "Name of the CloudWatch log group for Lambda function"
  value       = aws_cloudwatch_log_group.firehose_lambda_transform.name
}

# IAM Role Outputs
output "firehose_delivery_role_arn" {
  description = "ARN of the IAM role used by Kinesis Firehose for delivery"
  value       = aws_iam_role.firehose_delivery_role.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the IAM role used by Lambda function for execution"
  value       = aws_iam_role.lambda_iam_role.arn
}

# Kinesis Firehose Outputs
output "firehose_delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.kinesis_firehose.name
}

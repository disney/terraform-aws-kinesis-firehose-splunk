
output "cloudwatch_to_firehose_trust_arn" {
  value = aws_iam_role.cloudwatch_to_firehose_trust.arn
  description = "cloudwatch log subscription filter role_arn"
}

output "destination_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.kinesis_firehose.arn
  description = "cloudwatch log subscription filter destination_arn"
}

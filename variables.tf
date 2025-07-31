variable "region" {
  description = "DEPRECATED. The region of AWS you want to work in, such as us-west-2 or us-east-1 (deprecated: use `var.cloudwatch_log_regions` instead)"
  type        = string
  default     = null
}

variable "cloudwatch_log_regions" {
  description = "List of regions to allow CloudWatch logs to be shipped from. Set in Kinesis Firehose role's trust polucy"
  type        = list(string)
  default     = []
}

variable "hec_url" {
  description = "Splunk Kinesis URL for submitting CloudWatch logs to splunk"
  type        = string
}

variable "hec_token" {
  description = "Splunk security token needed to submit data to Splunk. Required if var.self_managed_hec_token is not specified."
  type        = string
  default     = null
}

variable "nodejs_runtime" {
  description = "Runtime version of nodejs for Lambda function"
  default     = "nodejs20.x"
  type        = string
}

variable "firehose_name" {
  description = "Name of the Kinesis Firehose"
  default     = "kinesis-firehose-to-splunk"
  type        = string
}

variable "kinesis_firehose_retry_duration" {
  description = "After an initial failure to deliver to Splunk, the total amount of time, in seconds between 0 to 7200, during which Firehose re-attempts delivery (including the first attempt). After this time has elapsed, the failed documents are written to Amazon S3. The default value is 300s. There will be no retry if the value is 0"
  type        = number
  default     = 300 # Seconds
}

variable "kinesis_firehose_buffer" {
  description = "https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#buffer_size"
  type        = number
  default     = 5 # Megabytes
}

variable "kinesis_firehose_buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination"
  type        = number
  default     = 300 # Seconds
}

variable "s3_prefix" {
  description = "Optional prefix (a slash after the prefix will show up as a folder in the s3 bucket).  The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files."
  type        = string
  default     = "kinesis-firehose/"
}

variable "hec_acknowledgment_timeout" {
  description = "The amount of time, in seconds between 180 and 600, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data."
  type        = number
  default     = 300
}

variable "hec_endpoint_type" {
  description = "Splunk HEC endpoint type; `Raw` or `Event`"
  type        = string
  default     = "Raw"
}

variable "s3_backup_mode" {
  description = "Defines how documents should be delivered to Amazon S3. Valid values are FailedEventsOnly and AllEvents."
  type        = string
  default     = "FailedEventsOnly"
}

variable "s3_compression_format" {
  description = "The compression format for what the Kinesis Firehose puts in the s3 bucket"
  type        = string
  default     = "GZIP"
}

variable "enable_fh_cloudwatch_logging" {
  description = "Enable kinesis firehose CloudWatch logging. (It only logs errors)"
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to put on the resource"
  default     = {}
}

variable "cloudwatch_log_retention" {
  description = "Length in days to keep CloudWatch logs of Kinesis Firehose"
  type        = number
  default     = 30
}

variable "log_stream_name" {
  description = "Name of the CloudWatch log stream for Kinesis Firehose CloudWatch log group"
  type        = string
  default     = "SplunkDelivery"
}

variable "s3_bucket_name" {
  description = "Name of the s3 bucket Kinesis Firehose uses for backups"
  type        = string
}

variable "s3_bucket_block_public_access_enabled" {
  description = "Set to 1 if you would like to add block public access settings for the s3 bucket Kinesis Firehose uses for backups"
  type        = number
  default     = 0
}

variable "encryption_context" {
  description = "aws_kms_secrets encryption context"
  type        = map(string)
  default     = {}
}

variable "kinesis_firehose_lambda_role_name" {
  description = "Name of IAM Role for Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format"
  type        = string
  default     = "KinesisFirehoseToLambaRole"
}

variable "kinesis_firehose_role_name" {
  description = "Name of IAM Role for the Kinesis Firehose"
  type        = string
  default     = "KinesisFirehoseRole"
}

variable "arn_cloudwatch_logs_to_ship" {
  description = "arn of the CloudWatch Log Group that you want to ship to Splunk."
  type        = string
  default     = null
}

variable "name_cloudwatch_logs_to_ship" {
  description = "Name of the CloudWatch Log Group that you want to ship to Splunk (single log group; leave empty to not create the subscription filter; see var.cloudwatch_log_group_names_to_ship for creating subscription filters for multiple log groups)."
  type        = string
  default     = null
}

variable "lambda_function_name" {
  description = "Name of the Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format"
  type        = string
  default     = "kinesis-firehose-transform"
}

variable "lambda_function_memory_size" {
  description = "Amount of memory in MB which Lambda Function can use at runtime. Defaults to 128"
  type        = number
  default     = 128
}

variable "lambda_function_timeout" {
  description = "The function execution time at which Lambda should terminate the function."
  type        = number
  default     = 180
}

variable "lambda_function_environment_variables" {
  description = "Environment variables for the lambda function"
  default     = {}
  type        = map(string)
}

variable "lambda_iam_policy_name" {
  description = "Name of the IAM policy that is attached to the IAM Role for the lambda transform function"
  type        = string
  default     = "Kinesis-Firehose-to-Splunk-Policy"
}

variable "kinesis_firehose_iam_policy_name" {
  description = "Name of the IAM Policy attached to IAM Role for the Kinesis Firehose"
  default     = "KinesisFirehose-Policy"
  type        = string
}

variable "cloudwatch_to_firehose_trust_iam_role_name" {
  description = "IAM Role name for CloudWatch to Kinesis Firehose subscription"
  type        = string
  default     = "CloudWatchToSplunkFirehoseTrust"
}

variable "cloudwatch_to_fh_access_policy_name" {
  description = "Name of IAM policy attached to the IAM role for CloudWatch to Kinesis Firehose subscription"
  type        = string
  default     = "KinesisCloudWatchToFirehosePolicy"
}

variable "cloudwatch_log_filter_name" {
  description = "Name of Log Filter for CloudWatch Log subscription to Kinesis Firehose"
  type        = string
  default     = "KinesisSubscriptionFilter"
}

variable "cloudwatch_log_group_names_to_ship" {
  description = "List of CloudWatch Log Group names that you want to ship to Splunk."
  type        = list(string)
  default     = null
}

variable "subscription_filter_pattern" {
  description = "Filter pattern for the CloudWatch Log Group subscription to the Kinesis Firehose. See [this](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for filter pattern info."
  type        = string
  default     = "" # nothing is being filtered
}

variable "local_lambda_file" {
  description = "The absolute path to an existing custom Lambda script"
  type        = string
  default     = null
}

variable "local_lambda_file_handler" {
  description = "Allows you to specify Lambda handler if using a local custom file for Lambda function"
  type        = string
  default     = null
}

variable "aws_s3_bucket_versioning" {
  description = "Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets."
  type        = string
  default     = null
}

variable "s3_bucket_object_lock_enabled" {
  description = "Indicates whether this bucket has an Object Lock configuration enabled. Valid values: Enabled."
  type        = string
  default     = null
}

variable "firehose_server_side_encryption_enabled" {
  description = "Enable SSE for Kinesis Firehose"
  type        = bool
  default     = false
}

variable "firehose_server_side_encryption_key_type" {
  description = "Type of SSE key to be used for encrypting the Firehose. Valid values are `AWS_OWNED_CMK` and `CUSTOMER_MANAGED_CMK`"
  type        = string
  default     = null
}

variable "firehose_server_side_encryption_key_arn" {
  description = "ARN of the key to be used for Firehose SSE"
  type        = string
  default     = null
}

variable "cloudwach_log_group_kms_key_id" {
  description = "KMS key ID of the key to use to encrypt the Cloudwatch log group"
  type        = string
  default     = null
}

variable "lambda_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations."
  type        = string
  default     = null
}

variable "lambda_tracing_config" {
  description = "Configures x-ray tracing for Lambda fuction. See valid values here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#mode"
  type        = string
  default     = null
}

variable "s3_bucket_server_side_encryption_kms_master_key_id" {
  description = "AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  type        = string
  default     = null
}

variable "s3_bucket_server_side_encryption_algorithm" {
  description = "(Required) Server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  type        = string
  default     = "AES256"
}

variable "s3_bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = null
}

variable "lambda_kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables."
  type        = string
  default     = null
}

############# 3rd Party Software ############
variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}
########### End 3rd Party Software ###########

variable "object_lock_configuration_token" {
  description = "S3 bucket object lock configuration token"
  type        = string
  default     = null
}

variable "object_lock_configuration_mode" {
  description = "Default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values: COMPLIANCE, GOVERNANCE"
  type        = string
  default     = null
}

variable "object_lock_configuration_days" {
  description = "Required if years is not specified. Number of days that you want to specify for the default retention period"
  type        = number
  default     = null
}

variable "object_lock_configuration_years" {
  description = "Required if days is not specified. Number of years that you want to specify for the default retention period"
  type        = number
  default     = null
}

variable "self_managed_hec_token" {
  description = "This variable allows for the user to have additional flexibility in how they pass in the HEC token. Perhaps they want to use a different tool than SSM or KMS encryption in their code base to encrypt it. Required if var.hec_token is not specified."
  type        = string
  sensitive   = true
  default     = null
}

variable "lambda_processing_buffer_size_in_mb" {
  description = "Lambda processing buffer size in mb."
  type        = number
  default     = 0.256
}

variable "lambda_processing_buffer_interval_in_seconds" {
  description = "Lambda processing buffer interval in seconds."
  type        = number
  default     = 61 # If 60 is the default, it is not stored in state and there are perpetual changes in the plan
}

variable "firehose_processing_enabled" {
  description = "Kinesis firehose processing enabled"
  type        = bool
  default     = true
}

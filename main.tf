locals {
  lambda_function_source_file = var.local_lambda_file != null ? var.local_lambda_file : "${path.module}/files/kinesis-firehose-cloudwatch-logs-processor.js"
  lambda_function_handler     = var.local_lambda_file_handler != null ? var.local_lambda_file_handler : "kinesis-firehose-cloudwatch-logs-processor.handler"
}

# Kenisis firehose stream
# Record Transformation Required, called "processing_configuration" in Terraform
resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose" {
  name        = var.firehose_name
  destination = "splunk"

  s3_configuration {
    role_arn           = aws_iam_role.kinesis_firehose.arn
    prefix             = var.s3_prefix
    bucket_arn         = aws_s3_bucket.kinesis_firehose_s3_bucket.arn
    buffer_size        = var.kinesis_firehose_buffer
    buffer_interval    = var.kinesis_firehose_buffer_interval
    compression_format = var.s3_compression_format
  }

  dynamic "server_side_encryption" {
    for_each = var.firehose_server_side_encryption_enabled == true ? [1] : []
    content {
      enabled  = var.firehose_server_side_encryption_enabled
      key_type = var.firehose_server_side_encryption_key_type
      key_arn  = var.firehose_server_side_encryption_key_arn
    }
  }

  splunk_configuration {
    hec_endpoint               = var.hec_url
    hec_token                  = data.aws_kms_secrets.splunk_hec_token.plaintext["hec_token"] != null ? data.aws_kms_secrets.splunk_hec_token.plaintext["hec_token"] : var.self_managed_hec_token
    hec_acknowledgment_timeout = var.hec_acknowledgment_timeout
    hec_endpoint_type          = var.hec_endpoint_type
    s3_backup_mode             = var.s3_backup_mode

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.firehose_lambda_transform.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.kinesis_firehose.arn
        }
        dynamic "parameters" {
          for_each = var.lambda_processing_buffer_size_in_mb != null ? [1] : []
          content {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = var.lambda_processing_buffer_size_in_mb
          }
        }
      }
    }

    cloudwatch_logging_options {
      enabled         = var.enable_fh_cloudwatch_logging
      log_group_name  = aws_cloudwatch_log_group.kinesis_logs.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_logs.name
    }
  }

  tags = var.tags
}

# S3 Bucket for Kinesis Firehose s3_backup_mode
resource "aws_s3_bucket" "kinesis_firehose_s3_bucket" {
  bucket              = var.s3_bucket_name
  object_lock_enabled = var.s3_bucket_object_lock_enabled

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "kinesis_firehose_s3_bucket_versioning" {
  count  = var.aws_s3_bucket_versioning == null ? 0 : 1
  bucket = aws_s3_bucket.kinesis_firehose_s3_bucket.id

  versioning_configuration {
    status = var.aws_s3_bucket_versioning
  }
}

resource "aws_s3_bucket_acl" "kinesis_firehose_s3_bucket" {
  bucket = aws_s3_bucket.kinesis_firehose_s3_bucket.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kinesis_firehose_s3_bucket" {
  bucket = aws_s3_bucket.kinesis_firehose_s3_bucket.bucket

  rule {
    bucket_key_enabled = var.s3_bucket_key_enabled

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_bucket_server_side_encryption_kms_master_key_id
      sse_algorithm     = var.s3_bucket_server_side_encryption_algorithm

    }
  }
}

resource "aws_s3_bucket_public_access_block" "kinesis_firehose_s3_bucket" {
  count  = var.s3_bucket_block_public_access_enabled
  bucket = aws_s3_bucket.kinesis_firehose_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object_lock_configuration" "kinesis_firehose_s3_lock" {
  count                 = var.s3_bucket_object_lock_enabled == "Enabled" ? 1 : 0
  bucket                = aws_s3_bucket.kinesis_firehose_s3_bucket.id
  object_lock_enabled   = var.s3_bucket_object_lock_enabled
  expected_bucket_owner = var.expected_bucket_owner
  token                 = var.object_lock_configuration_token

  rule {
    default_retention {
      mode  = var.object_lock_configuration_mode
      days  = var.object_lock_configuration_days
      years = var.object_lock_configuration_years
    }
  }
}

# Cloudwatch logging group for Kinesis Firehose
resource "aws_cloudwatch_log_group" "kinesis_logs" {
  name              = "/aws/kinesisfirehose/${var.firehose_name}"
  retention_in_days = var.cloudwatch_log_retention
  kms_key_id        = var.cloudwach_log_group_kms_key_id

  tags = var.tags
}

# Create the stream
resource "aws_cloudwatch_log_stream" "kinesis_logs" {
  name           = var.log_stream_name
  log_group_name = aws_cloudwatch_log_group.kinesis_logs.name
}

# handle the sensitivity of the hec_token variable
data "aws_kms_secrets" "splunk_hec_token" {
  count = var.hec_token == null ? 0 : 1
  secret {
    name    = "hec_token"
    payload = var.hec_token

    context = var.encryption_context
  }
}

# Role for the transformation Lambda function attached to the kinesis stream
resource "aws_iam_role" "kinesis_firehose_lambda" {
  name        = var.kinesis_firehose_lambda_role_name
  description = "Role for Lambda function to transformation CloudWatch logs into Splunk compatible format"

  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY


  tags = var.tags
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    actions = [
      "logs:GetLogEvents",
    ]

    resources = [
      var.arn_cloudwatch_logs_to_ship,
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.kinesis_firehose.arn,
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda_transform_policy" {
  name   = var.lambda_iam_policy_name
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_role_attachment" {
  role       = aws_iam_role.kinesis_firehose_lambda.name
  policy_arn = aws_iam_policy.lambda_transform_policy.arn
}

# Create the lambda function
# The lambda function to transform data from compressed format in Cloudwatch to something Splunk can handle (uncompressed)
resource "aws_lambda_function" "firehose_lambda_transform" {
  function_name                  = var.lambda_function_name
  description                    = "Transform data from CloudWatch format to Splunk compatible format"
  filename                       = data.archive_file.lambda_function.output_path
  role                           = aws_iam_role.kinesis_firehose_lambda.arn
  handler                        = local.lambda_function_handler
  source_code_hash               = data.archive_file.lambda_function.output_base64sha256
  runtime                        = var.nodejs_runtime
  timeout                        = var.lambda_function_timeout
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  dynamic "tracing_config" {
    for_each = var.lambda_tracing_config == null ? [] : [1]
    content {
      mode = var.lambda_tracing_config
    }
  }

  tags = var.tags
}

# kinesis-firehose-cloudwatch-logs-processor.js was taken by copy/paste from the AWS UI.  It is predefined blueprint
# code supplied to AWS by Splunk.
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = local.lambda_function_source_file
  output_path = "${path.module}/files/kinesis-firehose-cloudwatch-logs-processor.zip"
}

# Role for Kenisis Firehose
resource "aws_iam_role" "kinesis_firehose" {
  name        = var.kinesis_firehose_role_name
  description = "IAM Role for Kenisis Firehose"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Effect": "Allow"
    }
  ]
}
POLICY


  tags = var.tags
}

data "aws_iam_policy_document" "kinesis_firehose_policy_document" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.kinesis_firehose_s3_bucket.arn,
      "${aws_s3_bucket.kinesis_firehose_s3_bucket.arn}/*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "${aws_lambda_function.firehose_lambda_transform.arn}:$LATEST",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.kinesis_logs.arn,
      aws_cloudwatch_log_stream.kinesis_logs.arn,
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "kinesis_firehose_iam_policy" {
  name   = var.kinesis_firehose_iam_policy_name
  policy = data.aws_iam_policy_document.kinesis_firehose_policy_document.json
}

resource "aws_iam_role_policy_attachment" "kinesis_fh_role_attachment" {
  role       = aws_iam_role.kinesis_firehose.name
  policy_arn = aws_iam_policy.kinesis_firehose_iam_policy.arn
}

resource "aws_iam_role" "cloudwatch_to_firehose_trust" {
  name        = var.cloudwatch_to_firehose_trust_iam_role_name
  description = "Role for CloudWatch Log Group subscription"

  assume_role_policy = <<ROLE
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.${var.region}.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
ROLE

}

data "aws_iam_policy_document" "cloudwatch_to_fh_access_policy" {
  statement {
    actions = [
      "firehose:*",
    ]

    effect = "Allow"

    resources = [
      aws_kinesis_firehose_delivery_stream.kinesis_firehose.arn,
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    effect = "Allow"

    resources = [
      aws_iam_role.cloudwatch_to_firehose_trust.arn,
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_to_fh_access_policy" {
  name        = var.cloudwatch_to_fh_access_policy_name
  description = "Cloudwatch to Firehose Subscription Policy"
  policy      = data.aws_iam_policy_document.cloudwatch_to_fh_access_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_fh" {
  role       = aws_iam_role.cloudwatch_to_firehose_trust.name
  policy_arn = aws_iam_policy.cloudwatch_to_fh_access_policy.arn
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter" {
  name            = var.cloudwatch_log_filter_name
  role_arn        = aws_iam_role.cloudwatch_to_firehose_trust.arn
  destination_arn = aws_kinesis_firehose_delivery_stream.kinesis_firehose.arn
  log_group_name  = var.name_cloudwatch_logs_to_ship
  filter_pattern  = var.subscription_filter_pattern
}

# Send CloudWatch Logs to Splunk via Kinesis Firehose

This module configures a Kinesis Firehose, sets up a subscription for a desired CloudWatch Log Group to the Firehose, and sends the log data to Splunk.  A Lambda function is required to transform the CloudWatch Log data from "CloudWatch compressed format" to a format compatible with Splunk.  This module takes care of configuring this Lambda function.

## Usage Instructions

In order to send this data to Splunk you will need to first obtain an HEC Token from your Splunk administrator.

Once you have received the token, you can proceed forward in creating a `module` resource, such as the one in the Example below.

You will use a KMS key of your choice to encrypt the token, as it is sensitive.  See `hec_token` input variable below for more information.

**Note:** the user of this module is responsible for specifying the `provider {}` block for the AWS Terraform provider. As of v5.0.0 the provider block was removed from this module.

##### Example
```
module "kinesis_firehose" {
  source = "disney/kinesis-firehose-splunk/aws"
  region = "us-east-1"
  arn_cloudwatch_logs_to_ship = "arn:aws:logs:us-east-1:<aws_account_number>:log-group:/test/test01:*"  
  name_cloudwatch_logs_to_ship = "/test/test01"
  hec_token = "<KMS_encrypted_token>"
  kms_key_arn = "arn:aws:kms:us-east-1:<aws_account_number:key/<kms_key_id>"
  hec_url = "<Splunk_Kinesis_ingest_URL>"
  s3_bucket_name = "<mybucketname>"
}

```

### Inputs

| Variable Name | Description | Type  | Default | Required |
|---------------|-------------|-------|---------|----------|
| region | The region of AWS you want to work in, such as us-west-2 or us-east-1 | string | - | yes |
| arn_cloudwatch_logs_to_ship | arn of the CloudWatch Log Group that you want to ship to Splunk. | string | - | yes |
| name_cloudwatch_logs_to_ship | name of the CloudWatch Log Group that you want to ship to Splunk. | string | - | yes |
| hec_token | Splunk security token needed to submit data to Splunk vai HEC URL. Encyrpted with [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets#example-usage) procedure using a KMS key of your choice. If encrypted with specific encryption_context please set that variable. | string | - | yes |
| kms_key_arn | arn of the KMS key you used to encrypt the hec_token | string | - | yes |
| encryption_context | aws_kms_secrets encryption context | map | `{}` | no |
| hec_url | Splunk Kinesis URL for submitting CloudWatch logs to splunk | string | - | yes |
| hec_endpoint_type | The Splunk HEC endpoint type. | string | `Raw` | no |
| nodejs_runtime | Runtime version of nodejs for Lambda function | string | `nodejs12.x` | no |
| firehose_name  | Name of the Kinesis Firehose | string | `kinesis-firehose-to-splunk` | no |
| kinesis_firehose_buffer | Best to read it [here](https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#buffer_size) | integer | `5` | no |
| kinesis_firehose_buffer_interval | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | integer | `300` | no |
| s3_prefix | Optional prefix (a slash after the prefix will show up as a folder in the s3 bucket).  The "YYYY/MM/DD/HH" time format prefix is automatically used for delivered S3 files. | string | `kinesis-firehose/` | no |
| hec_acknowledgment_timeout | The amount of time, in seconds between 180 and 600, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data. | integer | `300` | no |
| s3_backup_mode | Defines how documents should be delivered to Amazon S3. Valid values are `FailedEventsOnly` and `AllEvents`. | string | `FailedEventsOnly` | no |
| enable_fh_cloudwatch_logging | Enable kinesis firehose CloudWatch logging. (It only logs errors). | boolean | `true` | no |
| tags | Map of tags to put on the resource | map | `null` | no |
| cloudwatch_log_retention | Length in days to keep CloudWatch logs of Kinesis Firehose | integer | `30` | no |
| log_stream_name | Name of the CloudWatch log stream for Kinesis Firehose CloudWatch log group | string | `SplunkDelivery` | no |
| s3_bucket_name  | Name of the S3 bucket Kinesis Firehose uses for backups | string | - | yes |
| s3_bucket_block_public_access_enabled | If statement if you would like to add the aws_s3_bucket_public_access_block terraform resource on s3 bucket Kinesis Firehose uses for backups. Set to 1 for enabled. | integer | `0` | no | 
| s3_compression_format | The compression format for what the Kinesis Firehose puts in the s3 bucket | string | `GZIP` | no |
| kinesis_firehose_lambda_role_name | Name of IAM Role for Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format | string | `KinesisFirehoseToLambaRole` | no |
| lambda_iam_policy_name | Name of the IAM policy that is attached to the IAM Role for the lambda transform function | string | `Kinesis-Firehose-to-Splunk-Policy` | no |
| lambda_function_timeout | The function execution time at which Lambda should terminate the function. | integer | `180` | no |
| kinesis_firehose_iam_policy_name | Name of the IAM Policy attached to IAM Role for the Kinesis Firehose | string | `KinesisFirehose-Policy` | no |
| cloudwatch_to_firehose_trust_iam_role_name | IAM Role name for CloudWatch to Kinesis Firehose subscription | string | `CloudWatchToSplunkFirehoseTrust` | no |
| cloudwatch_to_fh_access_policy_name | Name of IAM policy attached to the IAM role for CloudWatch to Kinesis Firehose subscription | string | `KinesisCloudWatchToFirehosePolicy` | no |
| cloudwatch_log_filter_name | Name of Log Filter for CloudWatch Log subscription to Kinesis Firehose | string | `KinesisSubscriptionFilter` | no |
| subscription_filter_pattern | Filter pattern for the CloudWatch Log Group subscription to the Kinesis Firehose. See [this](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for filter pattern info. | string | `""` (no filter) | no |
|local_lambda_file| The absolute path to an existing custom Lambda script| string | `null` | no |
|local_lambda_file_handler| Allows you to specify Lambda handler if using a local custom file for Lambda function | string| `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| cloudwatch_to_firehose_trust_arn | CloudWatch log subscription filter role ARN |
| destination_firehose_arn | CloudWatch log subscription filter Firehose destination arn |

#### Acknowledgements

_Author_
- Mitchell L. Cooper - Maintainer

_Reviewers_
- Ian Ward
- Justice London

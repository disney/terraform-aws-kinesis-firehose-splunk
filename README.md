[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/disney/terraform-aws-kinesis-firehose-splunk/master.svg)](https://results.pre-commit.ci/latest/github/disney/terraform-aws-kinesis-firehose-splunk/master)

# Send CloudWatch Logs to Splunk via Kinesis Firehose

This module configures a Kinesis Firehose, sets up a subscription for a desired CloudWatch Log Group to the Firehose, and sends the log data to Splunk.  A Lambda function is required to transform the CloudWatch Log data from "CloudWatch compressed format" to a format compatible with Splunk.  This module takes care of configuring this Lambda function.

## Usage Instructions

In order to send this data to Splunk you will need to first obtain an HEC Token from your Splunk administrator.

Once you have received the token, you can proceed forward in creating a `module` resource, such as the one in the Example below. You will use a KMS key of your choice to encrypt the token, as it is sensitive.

**Note:** the user of this module is responsible for specifying the `provider {}` block for the AWS Terraform provider. As of v5.0.0 the provider block was removed from this module.

##### Example
```hcl
module "kinesis_firehose" {
  source                       = "disney/kinesis-firehose-splunk/aws"
  region                       = "us-east-1"
  arn_cloudwatch_logs_to_ship  = "arn:aws:logs:us-east-1:<aws_account_number>:log-group:/test/test01:*"
  name_cloudwatch_logs_to_ship = "/test/test01"
  hec_url                      = "<Splunk_Kinesis_ingest_URL>"
  s3_bucket_name               = "<mybucketname>"

  ### HEC Token ###
  One of var.hec_token (default) OR var.self_managed_hec_token must be used to pass in the Splunk HEC token.
}

```
Please see the [S3 Life Cycle Rule example](examples/s3_bucket_lifecycle_rule.md) if you wish to configure them.

### v6.1.0 Passing in Splunk HEC Token
As of v6.1.0, there are two additional options available to pass in the HEC token:
  - You may pass it in via the new variable called `var.self_managed_hec_token` which gives you the flexibility to perhaps encrypt the token in your repo with a different tool of your choice, for example AWS SSM Parameter Store or [SOPS](https://github.com/mozilla/sops).

**By DEFAULT, for backwards compatibilty, it will default to using the KMS encrypted HEC token that this module previously required you to configure.**

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| archive | >= 2.3.0, < 3.0.0 |
| aws | >= 4.0.0, < 5.0.0 |

### Providers

| Name | Version |
|------|---------|
| archive | 2.3.0 |
| aws | 4.58.0 |

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.kinesis_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.kinesis_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_subscription_filter.cloudwatch_log_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.cloudwatch_to_fh_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kinesis_firehose_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_transform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudwatch_to_firehose_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kinesis_firehose_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_to_fh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kinesis_fh_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_lambda_function.firehose_lambda_transform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_s3_bucket.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.kinesis_firehose_s3_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_public_access_block.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.kinesis_firehose_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [archive_file.lambda_function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.cloudwatch_to_fh_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_secrets.splunk_hec_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) | data source |

### Modules

No modules.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| arn\_cloudwatch\_logs\_to\_ship | arn of the CloudWatch Log Group that you want to ship to Splunk. | `string` | n/a | yes |
| hec\_url | Splunk Kinesis URL for submitting CloudWatch logs to splunk | `string` | n/a | yes |
| name\_cloudwatch\_logs\_to\_ship | name of the CloudWatch Log Group that you want to ship to Splunk. | `string` | n/a | yes |
| region | The region of AWS you want to work in, such as us-west-2 or us-east-1 | `string` | n/a | yes |
| s3\_bucket\_name | Name of the s3 bucket Kinesis Firehose uses for backups | `string` | n/a | yes |
| aws\_s3\_bucket\_versioning | Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets. | `string` | `null` | no |
| cloudwach\_log\_group\_kms\_key\_id | KMS key ID of the key to use to encrypt the Cloudwatch log group | `string` | `null` | no |
| cloudwatch\_log\_filter\_name | Name of Log Filter for CloudWatch Log subscription to Kinesis Firehose | `string` | `"KinesisSubscriptionFilter"` | no |
| cloudwatch\_log\_retention | Length in days to keep CloudWatch logs of Kinesis Firehose | `number` | `30` | no |
| cloudwatch\_to\_fh\_access\_policy\_name | Name of IAM policy attached to the IAM role for CloudWatch to Kinesis Firehose subscription | `string` | `"KinesisCloudWatchToFirehosePolicy"` | no |
| cloudwatch\_to\_firehose\_trust\_iam\_role\_name | IAM Role name for CloudWatch to Kinesis Firehose subscription | `string` | `"CloudWatchToSplunkFirehoseTrust"` | no |
| enable\_fh\_cloudwatch\_logging | Enable kinesis firehose CloudWatch logging. (It only logs errors) | `bool` | `true` | no |
| encryption\_context | aws\_kms\_secrets encryption context | `map(string)` | `{}` | no |
| expected\_bucket\_owner | The account ID of the expected bucket owner | `string` | `null` | no |
| firehose\_name | Name of the Kinesis Firehose | `string` | `"kinesis-firehose-to-splunk"` | no |
| firehose\_server\_side\_encryption\_enabled | Enable SSE for Kinesis Firehose | `bool` | `false` | no |
| firehose\_server\_side\_encryption\_key\_arn | ARN of the key to be used for Firehose SSE | `string` | `null` | no |
| firehose\_server\_side\_encryption\_key\_type | Type of SSE key to be used for encrypting the Firehose. Valid values are `AWS_OWNED_CMK` and `CUSTOMER_MANAGED_CMK` | `string` | `null` | no |
| hec\_acknowledgment\_timeout | The amount of time, in seconds between 180 and 600, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data. | `number` | `300` | no |
| hec\_endpoint\_type | Splunk HEC endpoint type; `Raw` or `Event` | `string` | `"Raw"` | no |
| hec\_token | Splunk security token needed to submit data to Splunk | `string` | `null` | no |
| kinesis\_firehose\_buffer | https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#buffer_size | `number` | `5` | no |
| kinesis\_firehose\_buffer\_interval | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | `number` | `300` | no |
| kinesis\_firehose\_iam\_policy\_name | Name of the IAM Policy attached to IAM Role for the Kinesis Firehose | `string` | `"KinesisFirehose-Policy"` | no |
| kinesis\_firehose\_lambda\_role\_name | Name of IAM Role for Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format | `string` | `"KinesisFirehoseToLambaRole"` | no |
| kinesis\_firehose\_role\_name | Name of IAM Role for the Kinesis Firehose | `string` | `"KinesisFirehoseRole"` | no |
| lambda\_function\_name | Name of the Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format | `string` | `"kinesis-firehose-transform"` | no |
| lambda\_function\_timeout | The function execution time at which Lambda should terminate the function. | `number` | `180` | no |
| lambda\_iam\_policy\_name | Name of the IAM policy that is attached to the IAM Role for the lambda transform function | `string` | `"Kinesis-Firehose-to-Splunk-Policy"` | no |
| lambda\_processing\_buffer\_size\_in\_mb | Lambda processing buffer size in mb. It was noticed that the Lamba appeared to set this by default to `0.256` upon creation. | `number` | `null` | no |
| lambda\_reserved\_concurrent\_executions | Amount of reserved concurrent executions for this lambda function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations. | `string` | `null` | no |
| lambda\_tracing\_config | Configures x-ray tracing for Lambda fuction. See valid values here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#mode | `string` | `null` | no |
| lifecycle\_rule | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| local\_lambda\_file | The absolute path to an existing custom Lambda script | `string` | `null` | no |
| local\_lambda\_file\_handler | Allows you to specify Lambda handler if using a local custom file for Lambda function | `string` | `null` | no |
| log\_stream\_name | Name of the CloudWatch log stream for Kinesis Firehose CloudWatch log group | `string` | `"SplunkDelivery"` | no |
| nodejs\_runtime | Runtime version of nodejs for Lambda function | `string` | `"nodejs12.x"` | no |
| object\_lock\_configuration\_days | Required if years is not specified. Number of days that you want to specify for the default retention period | `number` | `null` | no |
| object\_lock\_configuration\_mode | Default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values: COMPLIANCE, GOVERNANCE | `string` | `null` | no |
| object\_lock\_configuration\_token | S3 bucket object lock configuration token | `string` | `null` | no |
| object\_lock\_configuration\_years | Required if days is not specified. Number of years that you want to specify for the default retention period | `number` | `null` | no |
| s3\_backup\_mode | Defines how documents should be delivered to Amazon S3. Valid values are FailedEventsOnly and AllEvents. | `string` | `"FailedEventsOnly"` | no |
| s3\_bucket\_block\_public\_access\_enabled | Set to 1 if you would like to add block public access settings for the s3 bucket Kinesis Firehose uses for backups | `number` | `0` | no |
| s3\_bucket\_key\_enabled | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `null` | no |
| s3\_bucket\_object\_lock\_enabled | Indicates whether this bucket has an Object Lock configuration enabled. Valid values: Enabled. | `string` | `null` | no |
| s3\_bucket\_server\_side\_encryption\_algorithm | (Required) Server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"AES256"` | no |
| s3\_bucket\_server\_side\_encryption\_kms\_master\_key\_id | AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms | `string` | `null` | no |
| s3\_compression\_format | The compression format for what the Kinesis Firehose puts in the s3 bucket | `string` | `"GZIP"` | no |
| s3\_prefix | Optional prefix (a slash after the prefix will show up as a folder in the s3 bucket).  The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. | `string` | `"kinesis-firehose/"` | no |
| self\_managed\_hec\_token | This variable allows for the user to have additional flexibility in how they pass in the HEC token. Perhaps they want to use a different tool than SSM or KMS encryption in their code base to encrypt it | `string` | `null` | no |
| subscription\_filter\_pattern | Filter pattern for the CloudWatch Log Group subscription to the Kinesis Firehose. See [this](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for filter pattern info. | `string` | `""` | no |
| tags | Map of tags to put on the resource | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_to\_firehose\_trust\_arn | cloudwatch log subscription filter role\_arn |
| destination\_firehose\_arn | cloudwatch log subscription filter - Firehose destination arn |
<!-- END_TF_DOCS -->

#### Acknowledgements

_Author_
- Mitchell L. Cooper - Maintainer

_Reviewers_
- Ian Ward
- Justice London

# Send CloudWatch Logs to Splunk via Kinesis Firehose

This module configures a Kinesis Firehose, sets up a subscription for a desired CloudWatch Log Group to the Firehose, and sends the log data to Splunk.  A Lambda function is required to transform the CloudWatch Log data from "CloudWatch compressed format" to a format compatible with Splunk.  This module takes care of configuring this Lambda function.

## Usage Instructions

In order to send this data to Splunk you will need to first obtain an HEC Token from your Splunk administrator.

Once you have received the token, you can proceed forward in creating a `module` resource, such as the one in the Example below. You will use a KMS key of your choice to encrypt the token, as it is sensitive.

**Note:** the user of this module is responsible for specifying the `provider {}` block for the AWS Terraform provider. As of v5.0.0 the provider block was removed from this module.

##### Example
```hcl
module "kinesis_firehose" {
  source                             = "disney/kinesis-firehose-splunk/aws"
  version                            = "<version>"
  cloudwatch_log_regions             = ["us-east-1", "us-west-2"]
  name_cloudwatch_logs_to_ship       = "/test/test01"
  cloudwatch_log_group_names_to_ship = ["/aws/svc/loggroup1", "log-group-2", "/aws/svc2/loggroup"]
  hec_url                            = "<Splunk_Kinesis_ingest_URL>"
  s3_bucket_name                     = "<mybucketname>"

  ### HEC Token ###
  One of var.hec_token (default) OR var.self_managed_hec_token must be used to pass in the Splunk HEC token.
}

```
Please see the [S3 Life Cycle Rule example](examples/s3_bucket_lifecycle_rule.md) if you wish to configure them.

## Splunk Cloud Customers
If you are a Splunk Cloud customer, once you have successfully deployed all the resources, you will need to ensure that your Splunk Cloud instance has the Kinesis Data Firehose egress CIDRs allow listed under `Server Settings > IP Allow List Management > HEC access for ingestion`.

For more details on the relevant CIDRs please reference this [article](https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-splunk-vpc).

### Upgrading from v6.0.0 to v7.0.0

If you choose to change the way you pass in your HEC token (see section below) when upgrading from v6.0.0 to v7.0.0, when you run `terraform apply`, you _might_ run into Terraform reporting that it is going to make changes to resources such as IAM policies when nothing has changed with them. Others have experienced this issue as well, please see this [issue](https://github.com/hashicorp/terraform/issues/32849).

#### v7.0.0 Passing in Splunk HEC Token
As of v7.0.0, there are two additional options available to pass in the HEC token:
  - You may pass the HEC token in via a variable called `var.self_managed_hec_token`, which gives you the flexibility to perhaps encrypt the token in your repo with a different tool of your choice. For example, AWS SSM Parameter Store or [SOPS](https://github.com/mozilla/sops).

**By DEFAULT, for backwards compatibilty, it will default to using the KMS encrypted HEC token that this module previously required you to configure.**

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.3.0, < 3.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.8.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hec_token_kms_secret"></a> [hec\_token\_kms\_secret](#module\_hec\_token\_kms\_secret) | ./modules/kms_secrets | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.kinesis_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.kinesis_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_subscription_filter.cloudwatch_log_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.cloudwatch_log_filters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
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
| [aws_s3_bucket_ownership_controls.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.kinesis_firehose_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.kinesis_firehose_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [archive_file.lambda_function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch_to_fh_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch_to_firehose_trust_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hec_url"></a> [hec\_url](#input\_hec\_url) | Splunk Kinesis URL for submitting CloudWatch logs to splunk | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the s3 bucket Kinesis Firehose uses for backups | `string` | n/a | yes |
| <a name="input_arn_cloudwatch_logs_to_ship"></a> [arn\_cloudwatch\_logs\_to\_ship](#input\_arn\_cloudwatch\_logs\_to\_ship) | arn of the CloudWatch Log Group that you want to ship to Splunk. | `string` | `null` | no |
| <a name="input_aws_s3_bucket_versioning"></a> [aws\_s3\_bucket\_versioning](#input\_aws\_s3\_bucket\_versioning) | Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets. | `string` | `null` | no |
| <a name="input_cloudwach_log_group_kms_key_id"></a> [cloudwach\_log\_group\_kms\_key\_id](#input\_cloudwach\_log\_group\_kms\_key\_id) | KMS key ID of the key to use to encrypt the Cloudwatch log group | `string` | `null` | no |
| <a name="input_cloudwatch_log_filter_name"></a> [cloudwatch\_log\_filter\_name](#input\_cloudwatch\_log\_filter\_name) | Name of Log Filter for CloudWatch Log subscription to Kinesis Firehose | `string` | `"KinesisSubscriptionFilter"` | no |
| <a name="input_cloudwatch_log_group_names_to_ship"></a> [cloudwatch\_log\_group\_names\_to\_ship](#input\_cloudwatch\_log\_group\_names\_to\_ship) | List of CloudWatch Log Group names that you want to ship to Splunk. | `list(string)` | `null` | no |
| <a name="input_cloudwatch_log_regions"></a> [cloudwatch\_log\_regions](#input\_cloudwatch\_log\_regions) | List of regions to allow CloudWatch logs to be shipped from. Set in Kinesis Firehose role's trust polucy | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_log_retention"></a> [cloudwatch\_log\_retention](#input\_cloudwatch\_log\_retention) | Length in days to keep CloudWatch logs of Kinesis Firehose | `number` | `30` | no |
| <a name="input_cloudwatch_to_fh_access_policy_name"></a> [cloudwatch\_to\_fh\_access\_policy\_name](#input\_cloudwatch\_to\_fh\_access\_policy\_name) | Name of IAM policy attached to the IAM role for CloudWatch to Kinesis Firehose subscription | `string` | `"KinesisCloudWatchToFirehosePolicy"` | no |
| <a name="input_cloudwatch_to_firehose_trust_iam_role_name"></a> [cloudwatch\_to\_firehose\_trust\_iam\_role\_name](#input\_cloudwatch\_to\_firehose\_trust\_iam\_role\_name) | IAM Role name for CloudWatch to Kinesis Firehose subscription | `string` | `"CloudWatchToSplunkFirehoseTrust"` | no |
| <a name="input_enable_fh_cloudwatch_logging"></a> [enable\_fh\_cloudwatch\_logging](#input\_enable\_fh\_cloudwatch\_logging) | Enable kinesis firehose CloudWatch logging. (It only logs errors) | `bool` | `true` | no |
| <a name="input_encryption_context"></a> [encryption\_context](#input\_encryption\_context) | aws\_kms\_secrets encryption context | `map(string)` | `{}` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | The account ID of the expected bucket owner | `string` | `null` | no |
| <a name="input_firehose_name"></a> [firehose\_name](#input\_firehose\_name) | Name of the Kinesis Firehose | `string` | `"kinesis-firehose-to-splunk"` | no |
| <a name="input_firehose_processing_enabled"></a> [firehose\_processing\_enabled](#input\_firehose\_processing\_enabled) | Kinesis firehose processing enabled | `bool` | `true` | no |
| <a name="input_firehose_server_side_encryption_enabled"></a> [firehose\_server\_side\_encryption\_enabled](#input\_firehose\_server\_side\_encryption\_enabled) | Enable SSE for Kinesis Firehose | `bool` | `false` | no |
| <a name="input_firehose_server_side_encryption_key_arn"></a> [firehose\_server\_side\_encryption\_key\_arn](#input\_firehose\_server\_side\_encryption\_key\_arn) | ARN of the key to be used for Firehose SSE | `string` | `null` | no |
| <a name="input_firehose_server_side_encryption_key_type"></a> [firehose\_server\_side\_encryption\_key\_type](#input\_firehose\_server\_side\_encryption\_key\_type) | Type of SSE key to be used for encrypting the Firehose. Valid values are `AWS_OWNED_CMK` and `CUSTOMER_MANAGED_CMK` | `string` | `null` | no |
| <a name="input_hec_acknowledgment_timeout"></a> [hec\_acknowledgment\_timeout](#input\_hec\_acknowledgment\_timeout) | The amount of time, in seconds between 180 and 600, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data. | `number` | `300` | no |
| <a name="input_hec_endpoint_type"></a> [hec\_endpoint\_type](#input\_hec\_endpoint\_type) | Splunk HEC endpoint type; `Raw` or `Event` | `string` | `"Raw"` | no |
| <a name="input_hec_token"></a> [hec\_token](#input\_hec\_token) | Splunk security token needed to submit data to Splunk. Required if var.self\_managed\_hec\_token is not specified. | `string` | `null` | no |
| <a name="input_kinesis_firehose_buffer"></a> [kinesis\_firehose\_buffer](#input\_kinesis\_firehose\_buffer) | https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#buffer_size | `number` | `5` | no |
| <a name="input_kinesis_firehose_buffer_interval"></a> [kinesis\_firehose\_buffer\_interval](#input\_kinesis\_firehose\_buffer\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | `number` | `300` | no |
| <a name="input_kinesis_firehose_iam_policy_name"></a> [kinesis\_firehose\_iam\_policy\_name](#input\_kinesis\_firehose\_iam\_policy\_name) | Name of the IAM Policy attached to IAM Role for the Kinesis Firehose | `string` | `"KinesisFirehose-Policy"` | no |
| <a name="input_kinesis_firehose_lambda_role_name"></a> [kinesis\_firehose\_lambda\_role\_name](#input\_kinesis\_firehose\_lambda\_role\_name) | Name of IAM Role for Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format | `string` | `"KinesisFirehoseToLambaRole"` | no |
| <a name="input_kinesis_firehose_retry_duration"></a> [kinesis\_firehose\_retry\_duration](#input\_kinesis\_firehose\_retry\_duration) | After an initial failure to deliver to Splunk, the total amount of time, in seconds between 0 to 7200, during which Firehose re-attempts delivery (including the first attempt). After this time has elapsed, the failed documents are written to Amazon S3. The default value is 300s. There will be no retry if the value is 0 | `number` | `300` | no |
| <a name="input_kinesis_firehose_role_name"></a> [kinesis\_firehose\_role\_name](#input\_kinesis\_firehose\_role\_name) | Name of IAM Role for the Kinesis Firehose | `string` | `"KinesisFirehoseRole"` | no |
| <a name="input_lambda_function_environment_variables"></a> [lambda\_function\_environment\_variables](#input\_lambda\_function\_environment\_variables) | Environment variables for the lambda function | `map(string)` | `{}` | no |
| <a name="input_lambda_function_memory_size"></a> [lambda\_function\_memory\_size](#input\_lambda\_function\_memory\_size) | Amount of memory in MB which Lambda Function can use at runtime. Defaults to 128 | `number` | `128` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the Lambda function that transforms CloudWatch data for Kinesis Firehose into Splunk compatible format | `string` | `"kinesis-firehose-transform"` | no |
| <a name="input_lambda_function_timeout"></a> [lambda\_function\_timeout](#input\_lambda\_function\_timeout) | The function execution time at which Lambda should terminate the function. | `number` | `180` | no |
| <a name="input_lambda_iam_policy_name"></a> [lambda\_iam\_policy\_name](#input\_lambda\_iam\_policy\_name) | Name of the IAM policy that is attached to the IAM Role for the lambda transform function | `string` | `"Kinesis-Firehose-to-Splunk-Policy"` | no |
| <a name="input_lambda_kms_key_arn"></a> [lambda\_kms\_key\_arn](#input\_lambda\_kms\_key\_arn) | Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables. | `string` | `null` | no |
| <a name="input_lambda_processing_buffer_interval_in_seconds"></a> [lambda\_processing\_buffer\_interval\_in\_seconds](#input\_lambda\_processing\_buffer\_interval\_in\_seconds) | Lambda processing buffer interval in seconds. | `number` | `61` | no |
| <a name="input_lambda_processing_buffer_size_in_mb"></a> [lambda\_processing\_buffer\_size\_in\_mb](#input\_lambda\_processing\_buffer\_size\_in\_mb) | Lambda processing buffer size in mb. | `number` | `0.256` | no |
| <a name="input_lambda_reserved_concurrent_executions"></a> [lambda\_reserved\_concurrent\_executions](#input\_lambda\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations. | `string` | `null` | no |
| <a name="input_lambda_tracing_config"></a> [lambda\_tracing\_config](#input\_lambda\_tracing\_config) | Configures x-ray tracing for Lambda fuction. See valid values here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#mode | `string` | `null` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| <a name="input_local_lambda_file"></a> [local\_lambda\_file](#input\_local\_lambda\_file) | The absolute path to an existing custom Lambda script | `string` | `null` | no |
| <a name="input_local_lambda_file_handler"></a> [local\_lambda\_file\_handler](#input\_local\_lambda\_file\_handler) | Allows you to specify Lambda handler if using a local custom file for Lambda function | `string` | `null` | no |
| <a name="input_log_stream_name"></a> [log\_stream\_name](#input\_log\_stream\_name) | Name of the CloudWatch log stream for Kinesis Firehose CloudWatch log group | `string` | `"SplunkDelivery"` | no |
| <a name="input_name_cloudwatch_logs_to_ship"></a> [name\_cloudwatch\_logs\_to\_ship](#input\_name\_cloudwatch\_logs\_to\_ship) | Name of the CloudWatch Log Group that you want to ship to Splunk (single log group; leave empty to not create the subscription filter; see var.cloudwatch\_log\_group\_names\_to\_ship for creating subscription filters for multiple log groups). | `string` | `null` | no |
| <a name="input_nodejs_runtime"></a> [nodejs\_runtime](#input\_nodejs\_runtime) | Runtime version of nodejs for Lambda function | `string` | `"nodejs20.x"` | no |
| <a name="input_object_lock_configuration_days"></a> [object\_lock\_configuration\_days](#input\_object\_lock\_configuration\_days) | Required if years is not specified. Number of days that you want to specify for the default retention period | `number` | `null` | no |
| <a name="input_object_lock_configuration_mode"></a> [object\_lock\_configuration\_mode](#input\_object\_lock\_configuration\_mode) | Default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values: COMPLIANCE, GOVERNANCE | `string` | `null` | no |
| <a name="input_object_lock_configuration_token"></a> [object\_lock\_configuration\_token](#input\_object\_lock\_configuration\_token) | S3 bucket object lock configuration token | `string` | `null` | no |
| <a name="input_object_lock_configuration_years"></a> [object\_lock\_configuration\_years](#input\_object\_lock\_configuration\_years) | Required if days is not specified. Number of years that you want to specify for the default retention period | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | DEPRECATED. The region of AWS you want to work in, such as us-west-2 or us-east-1 (deprecated: use `var.cloudwatch_log_regions` instead) | `string` | `null` | no |
| <a name="input_s3_backup_mode"></a> [s3\_backup\_mode](#input\_s3\_backup\_mode) | Defines how documents should be delivered to Amazon S3. Valid values are FailedEventsOnly and AllEvents. | `string` | `"FailedEventsOnly"` | no |
| <a name="input_s3_bucket_block_public_access_enabled"></a> [s3\_bucket\_block\_public\_access\_enabled](#input\_s3\_bucket\_block\_public\_access\_enabled) | Set to 1 if you would like to add block public access settings for the s3 bucket Kinesis Firehose uses for backups | `number` | `0` | no |
| <a name="input_s3_bucket_key_enabled"></a> [s3\_bucket\_key\_enabled](#input\_s3\_bucket\_key\_enabled) | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `null` | no |
| <a name="input_s3_bucket_object_lock_enabled"></a> [s3\_bucket\_object\_lock\_enabled](#input\_s3\_bucket\_object\_lock\_enabled) | Indicates whether this bucket has an Object Lock configuration enabled. Valid values: Enabled. | `string` | `null` | no |
| <a name="input_s3_bucket_server_side_encryption_algorithm"></a> [s3\_bucket\_server\_side\_encryption\_algorithm](#input\_s3\_bucket\_server\_side\_encryption\_algorithm) | (Required) Server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"AES256"` | no |
| <a name="input_s3_bucket_server_side_encryption_kms_master_key_id"></a> [s3\_bucket\_server\_side\_encryption\_kms\_master\_key\_id](#input\_s3\_bucket\_server\_side\_encryption\_kms\_master\_key\_id) | AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms | `string` | `null` | no |
| <a name="input_s3_compression_format"></a> [s3\_compression\_format](#input\_s3\_compression\_format) | The compression format for what the Kinesis Firehose puts in the s3 bucket | `string` | `"GZIP"` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | Optional prefix (a slash after the prefix will show up as a folder in the s3 bucket).  The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. | `string` | `"kinesis-firehose/"` | no |
| <a name="input_self_managed_hec_token"></a> [self\_managed\_hec\_token](#input\_self\_managed\_hec\_token) | This variable allows for the user to have additional flexibility in how they pass in the HEC token. Perhaps they want to use a different tool than SSM or KMS encryption in their code base to encrypt it. Required if var.hec\_token is not specified. | `string` | `null` | no |
| <a name="input_subscription_filter_pattern"></a> [subscription\_filter\_pattern](#input\_subscription\_filter\_pattern) | Filter pattern for the CloudWatch Log Group subscription to the Kinesis Firehose. See [this](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for filter pattern info. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to put on the resource | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_to_firehose_trust_arn"></a> [cloudwatch\_to\_firehose\_trust\_arn](#output\_cloudwatch\_to\_firehose\_trust\_arn) | cloudwatch log subscription filter role\_arn |
| <a name="output_destination_firehose_arn"></a> [destination\_firehose\_arn](#output\_destination\_firehose\_arn) | cloudwatch log subscription filter - Firehose destination arn |
<!-- END_TF_DOCS -->

#### Acknowledgements

_Author_
- Mitchell L. Cooper - Maintainer

_Reviewers_
- Ian Ward
- Justice London

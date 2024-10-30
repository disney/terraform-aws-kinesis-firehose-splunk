# Change Log for Terraform AWS Kinesis Firehose Splunk

## v9.0.4
 * Added resource `"aws_cloudwatch_log_group" "firehose_lambda_transform"` for transform Lamdba logs

## v9.0.3
 * Added `var.kinesis_firehose_retry_duration` and `var.lambda_function_memory_size` with appropriate defaults. Thanks [@ranga543](https://github.com/ranga543).

## v9.0.2
 * Use data resource `aws_partition` to discern current partition for IAM policy so that it can work in AWS China or AWS Gov.

## v9.0.1
 * Fix [#39](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/39) - Syntax error: Cannot use import statement outside a module. Added `package.json` file.
 * Added `.vscode` to `.gitignore` file.

## v9.0.0 - **Breaking Changes**
 * Fix [#36](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/36) - AWS SDK v3.x is what is packaged with `nodejs18.x` runtime. Updating Lambda code for NodeJS AWS SDK v3.x.
 * The Lambda code update is a breaking change because some users may still be on `nodejs16.x` runtime which uses NodeJS AWS SDK v2.x, per this [documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html).
 * Bumping default runtime to `nodejs20.x` since this runtime version uses the same AWS SDK v3.x version as `nodejs18.x`.

## v8.2.0
 * Fix [#34](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/34) - Add documentation note in README.md for Splunk Cloud customers. Thanks[@out-of-mana](https://github.com/out-of-mana)
 * Fix [#32](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/pull/32) - Enable Cloudwatch Logs Access From Multiple Regions. `var.region` is now Deprecated. Thanks [@bogdannazarenko](https://github.com/bogdannazarenko)
 * Expose Lambda environment variables. Thanks [@tlopo](https://github.com/tlopo).

## v8.1.0
 * Change `var.name_cloudwatch_logs_to_ship` to be non-mandatory. It will now default to `null` and the subscription filter will not be created if it is `null`. See `var.cloudwatch_log_group_names_to_ship` to create subscription filters to multiple log groups.
 * Fix [#27](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/27) - Add `var.cloudwatch_log_group_names_to_ship` to allow creating subscription filters to multiple log groups.
 * Fix [#28](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/28) - Change `var.arn_cloudwatch_logs_to_ship` to be non-mandatory. The ARN will now be derived automatically if `var.name_cloudwatch_logs_to_ship` is used (not `null`).
 * Update README.md with variable changes, and a new description for `var.cloudwatch_logs_to_ship`.

## v8.0.0 - **Breaking Changes**
 * Requires `>= 5.0.0, < 6.0.0` of the terraform aws [provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
 * Updated default value of `var.nodejs_runtime` to `nodejs18.x`
 * Updated `files\kinesis-firehose-cloudwatch-logs-processor.js` to latest version of AWS blueprint function code
 * Fix the resource `aws_kinesis_firehose_delivery_stream` to make it AWS provider v5 compliant
 * Fix s3 bucket ownership with new resource `aws_s3_bucket_ownership_controls`
 * Added `var.lambda_processing_buffer_interval_in_seconds`
 * Set default to `0.256` for `var.lambda_processing_buffer_size_in_mb`
 * Improved formatting of README.md

## 7.0.0
 * **Breaking Change** - Removed `var.kms_key_arn`
 * Update README.md with `terraform-docs`
 * Created Github actions pipelines
 * Support for SSE for the Kinesis Firehose
 * Added `reserved_concurrent_executions` parameter to Lambda function
 * Added `var.lambda_processing_buffer_size_in_mb` to optionally configure the parameter `BufferSizeInMBs` in the Kinesis Firehose
 * Updated all variables to specify `type`
 * Require less than version `5.0.0` of the AWS provider
 * Created NOTICE file
 * Fix [#19](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/18) - Support for S3 bucket Versioning, support for Object Locking, support for s3 bucket lifecycles
 * Fix [#18](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/18) - Allow the HEC token to be passed in via a new variable, `var.managed_hec_token`, allowing the user to encrypt it as they wish, perhaps via SSM Parameter Store or [SOPS](https://github.com/mozilla/sops)

## 6.0.0
 * Requires `>= 4.0.0` of the AWS provider; merged in [S3 changes](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/pull/15)
 * Update README for the correct location of `aws_kms_secrets` usage example
 * Added `*.zip` to `.gitignore` file

## 5.1.2
 * Update license

## 5.1.1
 * Update description for `var.local_lambda_file`; it does not have to be a NodeJS file

## 5.1.0
  * Fix [#10](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/10) - Support custom Lambda script, as well as the `handler` for the custom code

## 5.0.3
  * Require `>= 3.58.0` of the aws provider (fixes issue with privisioning a NodeJS 12.x Lambda)

## 5.0.2
  * Update README with `region` variable in the example

## 5.0.1
  * Remove mention of `aws_region` input variable in README.md. This variable is no longer needed.

## 5.0.0
  * Require Terraform 1.0.0 or greater (drops support for versions lower than 1.0.0)
  * Fix [#7](https://github.com/disney/terraform-aws-kinesis-firehose-splunk/issues/7) - Remove provider block, which is also recommended by Terraform as discussed [here](https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879)

## 4.0.0 - Breaking Changes - (thanks [ShawnUCD](https://github.com/ShawnUCD))
  * Require Terraform 0.13.0 or greater. Terraform 0.12.x is not longer being developed or patched (including backports) by Hashicorp
  * New providers block that is supported by Terraform 0.13.x and higher
  * Fixed typo in the `resource "aws_iam_role_policy_attachment" "kenisis_fh_role_attachment"` resource in `main.tf`

## 3.0.1
  * Added `outputs.tf`

## 3.0.0 - Breaking Change - (thanks [phundisk](https://github.com/phundisk))
  * Remove default value for S3 Backup Bucket; this input is now required as S3 bucket names must be globally unique so having a default value was N/A anyway
  * Remove region from resource aws_s3_bucket as that is not an parameter in the latest aws provider
  * Adjust the module to be able to support for TF 13
  * Update to the README to add information on hec_token encryption_context and that s3_bucket_name is required
  * Add version lock to min AWS provider since the aws_s3_bucket resource region was always optional anyways
  * Add new resource aws_s3_bucket_public_access_block which can be enabled optionally via TF variable

## 2.0.0 - Potentially Breaking Change
  * Upgrade lambda to `node12.x` runtime (thanks [kevinkuszyk](https://github.com/kevinkuszyk))
  * Add latest javascript from the lambda blueprint (thanks [kevinkuszyk](https://github.com/kevinkuszyk))
  * Update README

## 1.0.0 - Breaking Change
  * Upgraded for Terraform 12 compatibility (thanks [kevinkuszyk](https://github.com/kevinkuszyk))
  * Added git ignore file

## 0.1.0
  * Initial release

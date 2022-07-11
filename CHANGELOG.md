# Change Log for Terraform AWS Kinesis Firehose Splunk

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

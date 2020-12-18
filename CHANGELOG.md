# Change Log for Terraform AWS Kinesis Firehose Splunk

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

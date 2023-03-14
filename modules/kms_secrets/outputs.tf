output "hec_token_kms_secret" {
  value = data.aws_kms_secrets.splunk_hec_token.plaintext["hec_token"]
}

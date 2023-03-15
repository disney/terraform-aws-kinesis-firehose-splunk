data "aws_kms_secrets" "splunk_hec_token" {
  secret {
    name    = "hec_token"
    payload = var.hec_token
    context = var.encryption_context
  }
}

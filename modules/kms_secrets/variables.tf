variable "hec_token" {
  description = "Splunk security token needed to submit data to Splunk"
  type        = string
  default     = null
}

variable "encryption_context" {
  description = "aws_kms_secrets encryption context"
  type        = map(string)
  default     = {}
}

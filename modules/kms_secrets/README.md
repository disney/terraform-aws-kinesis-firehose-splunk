# Module for HEC Token Encrypted via KMS Key

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.11.0, < 7.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.58.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_kms_secrets.splunk_hec_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_encryption_context"></a> [encryption\_context](#input\_encryption\_context) | aws\_kms\_secrets encryption context | `map(string)` | `{}` | no |
| <a name="input_hec_token"></a> [hec\_token](#input\_hec\_token) | Splunk security token needed to submit data to Splunk | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_hec_token_kms_secret"></a> [hec\_token\_kms\_secret](#output\_hec\_token\_kms\_secret) | n/a |
<!-- END_TF_DOCS -->

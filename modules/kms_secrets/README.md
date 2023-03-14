# Module for HEC Token Encrypted via KMS Key

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| aws | >= 4.0.0, < 5.0.0 |

### Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0, < 5.0.0 |

### Resources

| Name | Type |
|------|------|
| [aws_kms_secrets.splunk_hec_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) | data source |

### Modules

No modules.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| encryption\_context | aws\_kms\_secrets encryption context | `map(string)` | `{}` | no |
| hec\_token | Splunk security token needed to submit data to Splunk | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| hec\_token\_kms\_secret | n/a |
<!-- END_TF_DOCS -->
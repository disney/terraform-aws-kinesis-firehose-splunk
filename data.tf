# data "aws_region" "current" {}

# data "aws_caller_identity" "current" {}

data "aws_cloudwatch_log_group" "cloudwatch_log_group_to_ship" {
  name = var.name_cloudwatch_logs_to_ship
}
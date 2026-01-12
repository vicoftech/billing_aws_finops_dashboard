# ========================================================================================
# AWS Cost and Usage Report (CUR) Dashboard - Outputs
# ========================================================================================

# ========================================================================================
# S3 BUCKET OUTPUTS
# ========================================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for billing data"
  value       = aws_s3_bucket.billing_csvs.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for billing data"
  value       = aws_s3_bucket.billing_csvs.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.billing_csvs.bucket_domain_name
}

# ========================================================================================
# CUR REPORT OUTPUTS
# ========================================================================================

output "cur_report_name" {
  description = "Name of the CUR report definition"
  value       = aws_cur_report_definition.billing_cur.report_name
}

output "cur_s3_prefix" {
  description = "S3 prefix where CUR files are delivered"
  value       = aws_cur_report_definition.billing_cur.s3_prefix
}

output "cur_report_arn" {
  description = "ARN of the CUR report definition"
  value       = aws_cur_report_definition.billing_cur.arn
}

output "cur_delivery_schedule" {
  description = "Time unit for CUR delivery"
  value       = aws_cur_report_definition.billing_cur.time_unit
}

# ========================================================================================
# GLUE OUTPUTS
# ========================================================================================

output "glue_database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.billing.name
}

output "glue_table_name" {
  description = "Name of the Glue table"
  value       = aws_glue_catalog_table.billing.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.billing_crawler.name
}

output "glue_crawler_arn" {
  description = "ARN of the Glue crawler"
  value       = aws_glue_crawler.billing_crawler.arn
}

# ========================================================================================
# ATHENA OUTPUTS
# ========================================================================================

output "athena_database_name" {
  description = "Name of the Athena database for queries"
  value       = aws_glue_catalog_database.billing.name
}

output "athena_table_name" {
  description = "Name of the Athena table for CUR data"
  value       = aws_glue_catalog_table.billing.name
}

output "athena_workgroup" {
  description = "Default Athena workgroup"
  value       = "primary"
}

# ========================================================================================
# LAMBDA OUTPUTS
# ========================================================================================

output "cur_trigger_lambda_name" {
  description = "Name of the Lambda function that triggers Glue crawler"
  value       = aws_lambda_function.cur_crawler_trigger.function_name
}

output "cur_trigger_lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.cur_crawler_trigger.arn
}

# ========================================================================================
# EVENTBRIDGE OUTPUTS
# ========================================================================================

output "cur_eventbridge_rule_name" {
  description = "Name of the EventBridge rule for CUR delivery"
  value       = aws_cloudwatch_event_rule.cur_delivery.name
}

output "cur_eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.cur_delivery.arn
}

# ========================================================================================
# EC2/GRAFANA OUTPUTS
# ========================================================================================

output "grafana_instance_id" {
  description = "ID of the EC2 instance running Grafana"
  value       = aws_instance.grafana.id
}

output "grafana_public_ip" {
  description = "Public IP address of the Grafana server"
  value       = aws_eip.grafana_eip.public_ip
}

output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = "http://${aws_eip.grafana_eip.public_ip}"
}

output "grafana_ssh_url" {
  description = "SSH connection string for Grafana server"
  value       = "ssh -i grafana-key.pem ec2-user@${aws_eip.grafana_eip.public_ip}"
}

# ========================================================================================
# SSH KEY OUTPUTS
# ========================================================================================

output "grafana_keypair_name" {
  description = "Name of the SSH key pair for Grafana access"
  value       = aws_key_pair.grafana_key.key_name
}

output "grafana_ssh_private_key" {
  description = "Private SSH key for Grafana server access (save this securely)"
  value       = tls_private_key.grafana_ssh_key.private_key_pem
  sensitive   = true
}

output "grafana_ssh_public_key" {
  description = "Public SSH key"
  value       = tls_private_key.grafana_ssh_key.public_key_openssh
}

# ========================================================================================
# IAM OUTPUTS
# ========================================================================================

output "glue_crawler_role_name" {
  description = "Name of the IAM role for Glue crawler"
  value       = aws_iam_role.glue_crawler_role.name
}

output "glue_crawler_role_arn" {
  description = "ARN of the IAM role for Glue crawler"
  value       = aws_iam_role.glue_crawler_role.arn
}

output "cur_lambda_role_name" {
  description = "Name of the IAM role for CUR Lambda function"
  value       = aws_iam_role.cur_lambda_role.name
}

output "cur_lambda_role_arn" {
  description = "ARN of the IAM role for CUR Lambda function"
  value       = aws_iam_role.cur_lambda_role.arn
}

# ========================================================================================
# SECURITY GROUP OUTPUTS
# ========================================================================================

output "grafana_security_group_id" {
  description = "ID of the security group for Grafana server"
  value       = aws_security_group.grafana_sg.id
}

output "grafana_security_group_name" {
  description = "Name of the security group for Grafana server"
  value       = aws_security_group.grafana_sg.name
}

# ========================================================================================
# MONITORING OUTPUTS
# ========================================================================================

output "cloudwatch_event_rule_cur_delivery" {
  description = "CloudWatch Event Rule for CUR file delivery monitoring"
  value       = aws_cloudwatch_event_rule.cur_delivery.arn
}

# ========================================================================================
# COST OPTIMIZATION OUTPUTS
# ========================================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost for this infrastructure"
  value       = "Approximately $15-25/month (t2.micro EC2 + S3 storage)"
}

output "cost_optimization_tips" {
  description = "Tips for cost optimization"
  value = [
    "Use reserved instances for production workloads",
    "Enable S3 lifecycle policies for CUR data",
    "Monitor and optimize Athena queries",
    "Consider spot instances for non-critical workloads"
  ]
}

# ========================================================================================
# QUICK START COMMANDS
# ========================================================================================

output "quick_start_commands" {
  description = "Commands to get started quickly"
  value = [
    "terraform output grafana_url",
    "terraform output grafana_ssh_private_key",
    "aws athena start-query-execution --query-string 'SELECT COUNT(*) FROM cur_report' --query-execution-context Database=${aws_glue_catalog_database.billing.name}",
    "./scripts/workspace-helper.ps1"
  ]
}

# ========================================================================================
# DASHBOARD URLS
# ========================================================================================

output "dashboard_urls" {
  description = "URLs for accessing dashboards and services"
  value = {
    grafana       = "http://${aws_eip.grafana_eip.public_ip}"
    athena_console = "https://${var.aws_region}.console.aws.amazon.com/athena/home"
    s3_console    = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.billing_csvs.bucket}"
    glue_console  = "https://${var.aws_region}.console.aws.amazon.com/glue/home"
  }
}

# ========================================================================================
# TROUBLESHOOTING OUTPUTS
# ========================================================================================

output "troubleshooting_info" {
  description = "Information for troubleshooting issues"
  value = {
    cur_delivery_logs    = "Check CloudWatch Logs for CUR delivery"
    glue_crawler_logs   = "Check Glue crawler run history"
    lambda_logs         = "Check CloudWatch logs for Lambda function"
    s3_bucket_location  = aws_s3_bucket.billing_csvs.bucket
    athena_database     = aws_glue_catalog_database.billing.name
  }
}

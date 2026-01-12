# AWS Cost Analytics Platform - Environment Configurations
# Copy these examples and customize for your environments

# ===========================================
# DEVELOPMENT ENVIRONMENT
# ===========================================

# dev.tfvars
aws_region   = "us-east-1"
aws_profile  = "bsj_dev"
project_name = "cost-analytics"

# Optional: Custom configurations for dev
# grafana_admin_password = "change-this-password"
# enable_detailed_monitoring = false

# ===========================================
# STAGING ENVIRONMENT
# ===========================================

# staging.tfvars
aws_region   = "us-east-1"
aws_profile  = "bsj_test"
project_name = "cost-analytics"

# Optional: Custom configurations for staging
# grafana_admin_password = "secure-staging-password"
# enable_detailed_monitoring = true

# ===========================================
# PRODUCTION ENVIRONMENT
# ===========================================

# prod.tfvars
aws_region   = "us-east-1"
aws_profile  = "bsj_prod"
project_name = "cost-analytics"

# Optional: Custom configurations for prod
# grafana_admin_password = "highly-secure-prod-password"
# enable_detailed_monitoring = true
# backup_retention_days = 365

# ===========================================
# ADVANCED CONFIGURATIONS
# ===========================================

# Multi-region deployment example
# prod-us-west.tfvars
# aws_region   = "us-west-2"
# aws_profile  = "bsj_prod"
# project_name = "cost-analytics-usw"

# High-availability configuration
# prod-ha.tfvars
# aws_region   = "us-east-1"
# aws_profile  = "bsj_prod"
# project_name = "cost-analytics"
# enable_multi_az = true
# enable_backup = true

# ===========================================
# AWS PROFILE CONFIGURATION
# ===========================================
# Configure your AWS profiles in ~/.aws/credentials:
#
# [bsj_dev]
# aws_access_key_id = YOUR_DEV_ACCESS_KEY
# aws_secret_access_key = YOUR_DEV_SECRET_KEY
#
# [bsj_test]
# aws_access_key_id = YOUR_TEST_ACCESS_KEY
# aws_secret_access_key = YOUR_TEST_SECRET_KEY
#
# [bsj_prod]
# aws_access_key_id = YOUR_PROD_ACCESS_KEY
# aws_secret_access_key = YOUR_PROD_SECRET_KEY
#
# Or use AWS SSO:
# aws configure sso --profile bsj_dev

# ===========================================
# WORKSPACE MANAGEMENT
# ===========================================
# Create and manage workspaces:
#
# # Create workspaces
# terraform workspace new dev
# terraform workspace new staging
# terraform workspace new prod
#
# # Switch between environments
# terraform workspace select dev
# terraform workspace select staging
# terraform workspace select prod
#
# # List all workspaces
# terraform workspace list
#
# # Deploy to specific environment
# terraform workspace select dev
# terraform plan -var-file="dev.tfvars"
# terraform apply -var-file="dev.tfvars"

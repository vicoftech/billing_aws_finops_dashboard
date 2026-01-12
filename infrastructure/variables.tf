# ========================================================================================
# AWS Cost and Usage Report (CUR) Dashboard - Variables
# ========================================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "bsj_dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "billing-dashboard"
}

# ========================================================================================
# INFRASTRUCTURE VARIABLES
# ========================================================================================

variable "instance_type" {
  description = "EC2 instance type for Grafana server"
  type        = string
  default     = "t2.micro"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana (change in production)"
  type        = string
  default     = "admin123"
  sensitive   = true
}

# ========================================================================================
# CUR CONFIGURATION
# ========================================================================================

variable "cur_time_unit" {
  description = "Time unit for CUR delivery (HOURLY or DAILY)"
  type        = string
  default     = "DAILY"

  validation {
    condition     = contains(["HOURLY", "DAILY"], var.cur_time_unit)
    error_message = "cur_time_unit must be either HOURLY or DAILY"
  }
}

variable "cur_format" {
  description = "Format for CUR delivery"
  type        = string
  default     = "Parquet"

  validation {
    condition     = contains(["Parquet", "textORcsv"], var.cur_format)
    error_message = "cur_format must be either Parquet or textORcsv"
  }
}

variable "cur_compression" {
  description = "Compression for CUR delivery"
  type        = string
  default     = "Parquet"

  validation {
    condition     = contains(["Parquet", "GZIP"], var.cur_compression)
    error_message = "cur_compression must be either Parquet or GZIP"
  }
}

variable "cur_additional_artifacts" {
  description = "Additional artifacts for CUR (ATHENA, REDSHIFT, QUICKSIGHT)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for artifact in var.cur_additional_artifacts : contains(
        ["ATHENA", "REDSHIFT", "QUICKSIGHT"], artifact
      )
    ])
    error_message = "cur_additional_artifacts must be a list containing only ATHENA, REDSHIFT, or QUICKSIGHT"
  }
}

# ========================================================================================
# GLUE CONFIGURATION
# ========================================================================================

variable "glue_crawler_schedule" {
  description = "Schedule for Glue crawler (cron expression)"
  type        = string
  default     = "cron(0 6 * * ? *)"  # Daily at 6 AM UTC
}

variable "glue_table_grouping_policy" {
  description = "Table grouping policy for Glue crawler"
  type        = string
  default     = "CombineCompatibleSchemas"

  validation {
    condition     = contains(["CombineCompatibleSchemas", "FindCommonSchema"], var.glue_table_grouping_policy)
    error_message = "glue_table_grouping_policy must be either CombineCompatibleSchemas or FindCommonSchema"
  }
}

# ========================================================================================
# MONITORING AND LOGGING
# ========================================================================================

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alerts"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of the valid CloudWatch log retention values"
  }
}

# ========================================================================================
# TAGS
# ========================================================================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Cost center for cost allocation"
  type        = string
  default     = "cloud-optimization"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "finops-team"
}

# ========================================================================================
# NETWORKING
# ========================================================================================

variable "vpc_id" {
  description = "VPC ID where resources will be created (leave empty for default VPC)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for EC2 instance (leave empty for default subnet)"
  type        = list(string)
  default     = []
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to connect via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Restrict in production
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to connect via HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Restrict in production
}

# ========================================================================================
# BACKUP AND DISASTER RECOVERY
# ========================================================================================

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup for critical data"
  type        = bool
  default     = false
}

# ========================================================================================
# PERFORMANCE AND COST OPTIMIZATION
# ========================================================================================

variable "enable_cost_allocation_tags" {
  description = "Enable cost allocation tags for better cost tracking"
  type        = bool
  default     = true
}

variable "reserved_instance_optimization" {
  description = "Enable reserved instance optimization recommendations"
  type        = bool
  default     = true
}

variable "savings_plan_optimization" {
  description = "Enable savings plan optimization recommendations"
  type        = bool
  default     = true
}

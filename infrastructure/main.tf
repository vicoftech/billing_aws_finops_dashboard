# ========================================================================================
# AWS Cost and Usage Report (CUR) Dashboard - Terraform Configuration
# FinOps Solution for Banco San Juan
# ========================================================================================

# Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

# AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = merge(local.common_tags, {
      ManagedBy   = "terraform"
      Environment = local.environment
      Project     = var.project_name
    })
  }
}

# Local values
locals {
  environment      = terraform.workspace
  common_tags = {
    CostCenter  = "cloud-optimization"
    Owner       = "finops-team"
    Project     = var.project_name
    Environment = local.environment
  }

  # Naming convention
  name_prefix = "${var.project_name}-${local.environment}"
}

# ========================================================================================
# DATA SOURCES
# ========================================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ========================================================================================
# S3 BUCKET FOR BILLING DATA
# ========================================================================================

resource "aws_s3_bucket" "billing_csvs" {
  bucket = "${local.name_prefix}-billing-csvs"

  tags = merge(local.common_tags, {
    Name = "Billing Data Bucket"
  })
}

resource "aws_s3_bucket_versioning" "billing_csvs" {
  bucket = aws_s3_bucket.billing_csvs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "billing_csvs" {
  bucket = aws_s3_bucket.billing_csvs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "billing_csvs" {
  bucket = aws_s3_bucket.billing_csvs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ========================================================================================
# S3 BUCKET POLICY FOR CUR
# ========================================================================================

resource "aws_s3_bucket_policy" "cur_bucket_policy" {
  bucket = aws_s3_bucket.billing_csvs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = aws_s3_bucket.billing_csvs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.billing_csvs.arn}/cur-reports-v2/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*"
          }
        }
      }
    ]
  })
}

# ========================================================================================
# GLUE DATABASE
# ========================================================================================

resource "aws_glue_catalog_database" "billing" {
  name = "${local.name_prefix}-billing"

  description = "Database for billing data catalog"

  parameters = {
    classification = "parquet"
  }
}

# ========================================================================================
# GLUE CATALOG TABLE
# ========================================================================================

resource "aws_glue_catalog_table" "billing" {
  name          = "cur_report"
  database_name = aws_glue_catalog_database.billing.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"                    = "parquet"
    "has_encrypted_data"               = "false"
    "parquet.compression"              = "SNAPPY"
    "projection.enabled"               = "true"
    "projection.billing_period.type"   = "date"
    "projection.billing_period.format" = "yyyyMMdd-yyyyMMdd"
    "projection.billing_period.range"  = "2024-01-01,NOW"
    "projection.billing_period.interval"= "1"
    "projection.billing_period.interval.unit" = "DAYS"
    "storage.location.template"        = "s3://${aws_s3_bucket.billing_csvs.bucket}/cur-reports-v2/$${billing_period}/"
  }

  partition_keys {
    name = "billing_period"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.billing_csvs.bucket}/cur-reports-v2/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "cur_parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    # CUR reports have many columns, let Glue Crawler infer the schema
    # Here we define the most common/important columns
    columns {
      name = "identity_line_item_id"
      type = "string"
    }

    columns {
      name = "identity_time_interval"
      type = "string"
    }

    columns {
      name = "bill_invoice_id"
      type = "string"
    }

    columns {
      name = "bill_billing_period_start_date"
      type = "string"
    }

    columns {
      name = "bill_billing_period_end_date"
      type = "string"
    }

    columns {
      name = "line_item_usage_account_id"
      type = "string"
    }

    columns {
      name = "bill_payer_account_id"
      type = "string"
    }

    columns {
      name = "bill_billing_entity"
      type = "string"
    }

    columns {
      name = "bill_tax_type"
      type = "string"
    }

    columns {
      name = "line_item_usage_start_date"
      type = "string"
    }

    columns {
      name = "line_item_usage_end_date"
      type = "string"
    }

    columns {
      name = "line_item_product_code"
      type = "string"
    }

    columns {
      name = "line_item_usage_type"
      type = "string"
    }

    columns {
      name = "line_item_operation"
      type = "string"
    }

    columns {
      name = "line_item_availability_zone"
      type = "string"
    }

    columns {
      name = "line_item_resource_id"
      type = "string"
    }

    columns {
      name = "line_item_usage_amount"
      type = "decimal(18,9)"
    }

    columns {
      name = "line_item_currency_code"
      type = "string"
    }

    columns {
      name = "line_item_unblended_rate"
      type = "decimal(18,9)"
    }

    columns {
      name = "line_item_unblended_cost"
      type = "decimal(18,9)"
    }

    columns {
      name = "line_item_blended_rate"
      type = "decimal(18,9)"
    }

    columns {
      name = "line_item_blended_cost"
      type = "decimal(18,9)"
    }

    columns {
      name = "pricing_public_on_demand_cost"
      type = "decimal(18,9)"
    }

    columns {
      name = "pricing_public_on_demand_rate"
      type = "decimal(18,9)"
    }

    columns {
      name = "reservation_amortized_upfront_fee_for_billing_period"
      type = "decimal(18,9)"
    }

    columns {
      name = "reservation_amortized_upfront_cost_for_usage"
      type = "decimal(18,9)"
    }

    columns {
      name = "reservation_recurring_fee_for_usage"
      type = "decimal(18,9)"
    }

    columns {
      name = "reservation_unused_amortized_upfront_fee_for_billing_period"
      type = "decimal(18,9)"
    }

    columns {
      name = "reservation_unused_recurring_fee"
      type = "decimal(18,9)"
    }

    columns {
      name = "savings_plan_amortized_upfront_commitment_for_billing_period"
      type = "decimal(18,9)"
    }

    columns {
      name = "savings_plan_recurring_commitment_for_billing_period"
      type = "decimal(18,9)"
    }

    columns {
      name = "savings_plan_used_commitment"
      type = "decimal(18,9)"
    }

    columns {
      name = "savings_plan_savings_plan_effective_cost"
      type = "decimal(18,9)"
    }
  }
}

# ========================================================================================
# GLUE CRAWLER
# ========================================================================================

resource "aws_glue_crawler" "billing_crawler" {
  name          = "${local.name_prefix}-billing-crawler"
  database_name = aws_glue_catalog_database.billing.name
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.billing_csvs.bucket}/cur-reports-v2/"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = merge(local.common_tags, {
    Name = "Billing Crawler"
  })
}

# ========================================================================================
# IAM ROLES AND POLICIES
# ========================================================================================

# Glue Crawler Role
resource "aws_iam_role" "glue_crawler_role" {
  name = "${local.name_prefix}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "Glue Crawler Role"
  })
}

# Glue Crawler Policy
resource "aws_iam_role_policy" "glue_crawler_s3" {
  name = "${local.name_prefix}-glue-crawler-s3-policy"
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.billing_csvs.arn,
          "${aws_s3_bucket.billing_csvs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed policy for Glue
resource "aws_iam_role_policy_attachment" "glue_crawler_service" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# ========================================================================================
# CUR REPORT DEFINITION
# ========================================================================================

resource "aws_cur_report_definition" "billing_cur" {
  report_name                = "${local.name_prefix}-billing-report"
  time_unit                  = "DAILY"  # ← Entrega diaria para mejor compatibilidad
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.billing_csvs.bucket
  s3_prefix                  = "cur-reports-v2"  # ← Nuevo prefijo para evitar archivos problemáticos
  s3_region                  = var.aws_region

  # Removido additional_artifacts para evitar problemas de metadata
  additional_artifacts = []

  refresh_closed_reports = true
  report_versioning      = "OVERWRITE_REPORT"

  tags = merge(local.common_tags, {
    Name = "Billing CUR Report"
  })

  # Ensure bucket policy is created first
  depends_on = [aws_s3_bucket_policy.cur_bucket_policy]
}

# ========================================================================================
# LAMBDA FUNCTION FOR CUR CRAWLER TRIGGER
# ========================================================================================

# Lambda Role
resource "aws_iam_role" "cur_lambda_role" {
  name = "${local.name_prefix}-cur-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "CUR Lambda Role"
  })
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "cur_lambda_basic" {
  role       = aws_iam_role.cur_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Glue Policy
resource "aws_iam_role_policy" "cur_lambda_glue" {
  name = "${local.name_prefix}-cur-lambda-glue-policy"
  role = aws_iam_role.cur_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartCrawler",
          "glue:GetCrawler",
          "glue:GetCrawlerMetrics"
        ]
        Resource = aws_glue_crawler.billing_crawler.arn
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "cur_crawler_trigger" {
  filename         = data.archive_file.cur_trigger_lambda_zip.output_path
  function_name    = "${local.name_prefix}-cur-crawler-trigger"
  role            = aws_iam_role.cur_lambda_role.arn
  handler         = "cur_trigger.lambda_handler"
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      CRAWLER_NAME = aws_glue_crawler.billing_crawler.name
    }
  }

  tags = merge(local.common_tags, {
    Name = "CUR Crawler Trigger"
  })
}

# Lambda Archive
data "archive_file" "cur_trigger_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/cur_trigger_lambda.zip"
  excludes    = ["lambda_function.py"]  # Exclude the main billing processor
}

# ========================================================================================
# EVENTBRIDGE RULE FOR CUR DELIVERY
# ========================================================================================

resource "aws_cloudwatch_event_rule" "cur_delivery" {
  name        = "${local.name_prefix}-cur-delivery"
  description = "Trigger Glue crawler when CUR files are delivered"

  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.billing_csvs.bucket]
      }
      object = {
        key = [{
          prefix = "cur-reports-v2/"
        }]
      }
    }
  })

  tags = merge(local.common_tags, {
    Name = "CUR Delivery Rule"
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "cur_crawler" {
  rule      = aws_cloudwatch_event_rule.cur_delivery.name
  target_id = "CURCrawlerTriggerLambda"
  arn       = aws_lambda_function.cur_crawler_trigger.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cur_crawler_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cur_delivery.arn
}

# ========================================================================================
# GLUE CRAWLER TRIGGER (SCHEDULED)
# ========================================================================================

resource "aws_glue_trigger" "billing_crawler_trigger" {
  name     = "${local.name_prefix}-billing-crawler-trigger"
  type     = "SCHEDULED"
  schedule = "cron(0 6 * * ? *)"  # Daily at 6 AM UTC

  actions {
    crawler_name = aws_glue_crawler.billing_crawler.name
  }

  tags = merge(local.common_tags, {
    Name = "Billing Crawler Trigger"
  })
}

# ========================================================================================
# EC2 INSTANCE WITH GRAFANA
# ========================================================================================

# Security Group for Grafana
resource "aws_security_group" "grafana_sg" {
  name        = "${local.name_prefix}-grafana-sg"
  description = "Security group for Grafana EC2 instance"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to your IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Grafana Security Group"
  })
}

# EC2 Instance
resource "aws_instance" "grafana" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
  key_name               = aws_key_pair.grafana_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              # Install Grafana
              docker run -d \
                --name grafana \
                -p 3000:3000 \
                -e "GF_SECURITY_ADMIN_PASSWORD=admin123" \
                grafana/grafana:latest

              # Install Nginx for reverse proxy
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = merge(local.common_tags, {
    Name = "Grafana Server"
  })
}

# Elastic IP for Grafana
resource "aws_eip" "grafana_eip" {
  instance = aws_instance.grafana.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "Grafana EIP"
  })
}

# ========================================================================================
# SSH KEY PAIR
# ========================================================================================

resource "tls_private_key" "grafana_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "grafana_key" {
  key_name   = "${local.name_prefix}-grafana-key"
  public_key = tls_private_key.grafana_ssh_key.public_key_openssh

  tags = merge(local.common_tags, {
    Name = "Grafana SSH Key"
  })
}

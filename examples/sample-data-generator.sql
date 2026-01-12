-- ========================================================================================
-- SAMPLE DATA GENERATOR FOR FINOPS DASHBOARD TESTING
-- Generate mock CUR data for dashboard testing before real data arrives
-- ========================================================================================

-- Create sample data table (run this in Athena)
CREATE TABLE cur_report_sample AS

-- Generate sample EC2 instances data
SELECT
    CAST('i-1234567890abcdef0' AS VARCHAR) as identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) as billing_period,
    CAST('121490076910' AS VARCHAR) as line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) as bill_payer_account_id,
    CAST('AmazonEC2' AS VARCHAR) as line_item_product_code,
    CAST('BoxUsage:t2.micro' AS VARCHAR) as line_item_usage_type,
    CAST('RunInstances' AS VARCHAR) as line_item_operation,
    CAST('us-east-1a' AS VARCHAR) as line_item_availability_zone,
    CAST('i-1234567890abcdef0' AS VARCHAR) as line_item_resource_id,
    CAST(730.0 AS DECIMAL(18,9)) as line_item_usage_amount,
    CAST('Hrs' AS VARCHAR) as line_item_currency_code,
    CAST(0.0116 AS DECIMAL(18,9)) as line_item_unblended_rate,
    CAST(8.47 AS DECIMAL(18,9)) as line_item_unblended_cost,
    CAST(0.0116 AS DECIMAL(18,9)) as line_item_blended_rate,
    CAST(8.47 AS DECIMAL(18,9)) as line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) as line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) as bill_billing_period_end_date

UNION ALL

-- Generate sample RDS instance data
SELECT
    CAST('db-1234567890abcdef0' AS VARCHAR) as identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) as billing_period,
    CAST('121490076910' AS VARCHAR) as line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) as bill_payer_account_id,
    CAST('AmazonRDS' AS VARCHAR) as line_item_product_code,
    CAST('InstanceUsage:db.t3.micro' AS VARCHAR) as line_item_usage_type,
    CAST('CreateDBInstance' AS VARCHAR) as line_item_operation,
    CAST('us-east-1a' AS VARCHAR) as line_item_availability_zone,
    CAST('my-database' AS VARCHAR) as line_item_resource_id,
    CAST(730.0 AS DECIMAL(18,9)) as line_item_usage_amount,
    CAST('Hrs' AS VARCHAR) as line_item_currency_code,
    CAST(0.017 AS DECIMAL(18,9)) as line_item_unblended_rate,
    CAST(12.41 AS DECIMAL(18,9)) as line_item_unblended_cost,
    CAST(0.017 AS DECIMAL(18,9)) as line_item_blended_rate,
    CAST(12.41 AS DECIMAL(18,9)) as line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) as line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) as bill_billing_period_end_date

UNION ALL

-- Generate sample Lambda function data
SELECT
    CAST('lambda-1234567890abcdef0' AS VARCHAR) as identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) as billing_period,
    CAST('121490076910' AS VARCHAR) as line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) as bill_payer_account_id,
    CAST('AWSLambda' AS VARCHAR) as line_item_product_code,
    CAST('Request' AS VARCHAR) as line_item_usage_type,
    CAST('Invoke' AS VARCHAR) as line_item_operation,
    CAST('us-east-1' AS VARCHAR) as line_item_availability_zone,
    CAST('my-lambda-function' AS VARCHAR) as line_item_resource_id,
    CAST(1000000.0 AS DECIMAL(18,9)) as line_item_usage_amount,
    CAST('Requests' AS VARCHAR) as line_item_currency_code,
    CAST(0.0000002 AS DECIMAL(18,9)) as line_item_unblended_rate,
    CAST(0.20 AS DECIMAL(18,9)) as line_item_unblended_cost,
    CAST(0.0000002 AS DECIMAL(18,9)) as line_item_blended_rate,
    CAST(0.20 AS DECIMAL(18,9)) as line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) as line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) as bill_billing_period_end_date

UNION ALL

-- Generate sample S3 storage data
SELECT
    CAST('s3-1234567890abcdef0' AS VARCHAR) as identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) as billing_period,
    CAST('121490076910' AS VARCHAR) as line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) as bill_payer_account_id,
    CAST('AmazonS3' AS VARCHAR) as line_item_product_code,
    CAST('Storage' AS VARCHAR) as line_item_usage_type,
    CAST('StandardStorage' AS VARCHAR) as line_item_operation,
    CAST('us-east-1' AS VARCHAR) as line_item_availability_zone,
    CAST('my-bucket' AS VARCHAR) as line_item_resource_id,
    CAST(100.0 AS DECIMAL(18,9)) as line_item_usage_amount,
    CAST('GB' AS VARCHAR) as line_item_currency_code,
    CAST(0.023 AS DECIMAL(18,9)) as line_item_unblended_rate,
    CAST(2.30 AS DECIMAL(18,9)) as line_item_unblended_cost,
    CAST(0.023 AS DECIMAL(18,9)) as line_item_blended_rate,
    CAST(2.30 AS DECIMAL(18,9)) as line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) as line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) as bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) as bill_billing_period_end_date;

-- ========================================================================================
-- VERIFICATION QUERIES
-- ========================================================================================

-- Check total cost
SELECT SUM(line_item_blended_cost) as total_cost
FROM cur_report_sample;

-- Check resources count
SELECT COUNT(DISTINCT line_item_resource_id) as active_resources
FROM cur_report_sample
WHERE line_item_resource_id IS NOT NULL;

-- Check services
SELECT line_item_product_code, SUM(line_item_blended_cost) as total_cost
FROM cur_report_sample
GROUP BY line_item_product_code
ORDER BY total_cost DESC;

-- ========================================================================================
-- HOW TO USE THIS SAMPLE DATA
-- ========================================================================================

/*
1. Run the CREATE TABLE statement above in Amazon Athena
2. Import the dashboard: examples/finops-dashboard-athena.json
3. Change the table name in dashboard queries from 'cur_report' to 'cur_report_sample'
4. Or rename the table: ALTER TABLE cur_report_sample RENAME TO cur_report;

This will give you a working dashboard with realistic sample data while waiting
for the actual CUR data to be generated.
*/

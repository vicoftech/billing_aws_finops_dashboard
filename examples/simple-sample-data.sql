-- ========================================================================================
-- SIMPLE SAMPLE DATA FOR FINOPS DASHBOARD TESTING
-- Run this in Athena (Database: billing-dashboard_dev_billing)
-- ========================================================================================

-- Step 1: Create the table
CREATE TABLE cur_report_sample (
    identity_line_item_id STRING,
    billing_period STRING,
    line_item_usage_account_id STRING,
    bill_payer_account_id STRING,
    line_item_product_code STRING,
    line_item_usage_type STRING,
    line_item_operation STRING,
    line_item_availability_zone STRING,
    line_item_resource_id STRING,
    line_item_usage_amount DECIMAL(18,9),
    line_item_currency_code STRING,
    line_item_unblended_rate DECIMAL(18,9),
    line_item_unblended_cost DECIMAL(18,9),
    line_item_blended_rate DECIMAL(18,9),
    line_item_blended_cost DECIMAL(18,9),
    line_item_usage_start_date STRING,
    line_item_usage_end_date STRING,
    bill_billing_period_start_date STRING,
    bill_billing_period_end_date STRING
);

-- Step 2: Insert sample data
INSERT INTO cur_report_sample VALUES
-- EC2 Instance
('i-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonEC2', 'BoxUsage:t2.micro', 'RunInstances', 'us-east-1a', 'i-1234567890abcdef0',
 730.0, 'Hrs', 0.0116, 8.47, 0.0116, 8.47,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

-- RDS Database
('db-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonRDS', 'InstanceUsage:db.t3.micro', 'CreateDBInstance', 'us-east-1a', 'my-database',
 730.0, 'Hrs', 0.017, 12.41, 0.017, 12.41,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

-- Lambda Function
('lambda-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AWSLambda', 'Request', 'Invoke', 'us-east-1', 'my-lambda-function',
 1000000.0, 'Requests', 0.0000002, 0.20, 0.0000002, 0.20,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

-- S3 Storage
('s3-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonS3', 'Storage', 'StandardStorage', 'us-east-1', 'my-bucket',
 100.0, 'GB', 0.023, 2.30, 0.023, 2.30,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z');

-- ========================================================================================
-- VERIFICATION QUERIES - Run these after creating and populating the table
-- ========================================================================================

-- Query 1: Check total data
SELECT COUNT(*) as total_rows FROM cur_report_sample;

-- Query 2: Check total cost
SELECT SUM(line_item_blended_cost) as total_cost FROM cur_report_sample;

-- Query 3: Check services
SELECT
    line_item_product_code,
    SUM(line_item_blended_cost) as cost,
    COUNT(*) as records
FROM cur_report_sample
GROUP BY line_item_product_code
ORDER BY cost DESC;

-- Query 4: Check resources
SELECT
    line_item_product_code as service,
    COUNT(DISTINCT line_item_resource_id) as resources,
    SUM(line_item_blended_cost) as total_cost
FROM cur_report_sample
GROUP BY line_item_product_code
ORDER BY resources DESC;

-- ========================================================================================
-- HOW TO USE THIS IN GRAFANA
-- ========================================================================================

/*
1. Execute this entire SQL file in Athena (both CREATE and INSERT statements)
2. Verify the data with the queries above
3. Import the dashboard: examples/finops-dashboard-athena.json
4. In Grafana, when importing:
   - Select Athena as data source
   - Change all queries from 'cur_report' to 'cur_report_sample'
   - Save the dashboard

This should work without database name issues!
*/

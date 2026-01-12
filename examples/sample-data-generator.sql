-- ========================================================================================
-- AWS CUR SAMPLE DATA GENERATOR FOR FINOPS DASHBOARD
-- Database: billing-dashboard_dev_billing
-- Table: cur_report_sample
-- Purpose: Generate realistic mock CUR data for dashboard testing
-- ========================================================================================

-- Create sample CUR data table with realistic AWS billing data
-- Run this query in Amazon Athena console

CREATE TABLE billing-dashboard_dev_billing.cur_report_sample AS

-- ========================================================================================
-- SAMPLE EC2 INSTANCE DATA
-- ========================================================================================
SELECT
    CAST('i-1234567890abcdef0' AS VARCHAR) AS identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) AS billing_period,
    CAST('121490076910' AS VARCHAR) AS line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) AS bill_payer_account_id,
    CAST('AmazonEC2' AS VARCHAR) AS line_item_product_code,
    CAST('BoxUsage:t2.micro' AS VARCHAR) AS line_item_usage_type,
    CAST('RunInstances' AS VARCHAR) AS line_item_operation,
    CAST('us-east-1a' AS VARCHAR) AS line_item_availability_zone,
    CAST('i-1234567890abcdef0' AS VARCHAR) AS line_item_resource_id,
    CAST(730.0 AS DECIMAL(18,9)) AS line_item_usage_amount,
    CAST('Hrs' AS VARCHAR) AS line_item_currency_code,
    CAST(0.0116 AS DECIMAL(18,9)) AS line_item_unblended_rate,
    CAST(8.47 AS DECIMAL(18,9)) AS line_item_unblended_cost,
    CAST(0.0116 AS DECIMAL(18,9)) AS line_item_blended_rate,
    CAST(8.47 AS DECIMAL(18,9)) AS line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) AS line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_end_date

UNION ALL

-- ========================================================================================
-- SAMPLE RDS DATABASE DATA
-- ========================================================================================
SELECT
    CAST('db-1234567890abcdef0' AS VARCHAR) AS identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) AS billing_period,
    CAST('121490076910' AS VARCHAR) AS line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) AS bill_payer_account_id,
    CAST('AmazonRDS' AS VARCHAR) AS line_item_product_code,
    CAST('InstanceUsage:db.t3.micro' AS VARCHAR) AS line_item_usage_type,
    CAST('CreateDBInstance' AS VARCHAR) AS line_item_operation,
    CAST('us-east-1a' AS VARCHAR) AS line_item_availability_zone,
    CAST('my-database' AS VARCHAR) AS line_item_resource_id,
    CAST(730.0 AS DECIMAL(18,9)) AS line_item_usage_amount,
    CAST('Hrs' AS VARCHAR) AS line_item_currency_code,
    CAST(0.017 AS DECIMAL(18,9)) AS line_item_unblended_rate,
    CAST(12.41 AS DECIMAL(18,9)) AS line_item_unblended_cost,
    CAST(0.017 AS DECIMAL(18,9)) AS line_item_blended_rate,
    CAST(12.41 AS DECIMAL(18,9)) AS line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) AS line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_end_date

UNION ALL

-- ========================================================================================
-- SAMPLE LAMBDA FUNCTION DATA
-- ========================================================================================
SELECT
    CAST('lambda-1234567890abcdef0' AS VARCHAR) AS identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) AS billing_period,
    CAST('121490076910' AS VARCHAR) AS line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) AS bill_payer_account_id,
    CAST('AWSLambda' AS VARCHAR) AS line_item_product_code,
    CAST('Request' AS VARCHAR) AS line_item_usage_type,
    CAST('Invoke' AS VARCHAR) AS line_item_operation,
    CAST('us-east-1' AS VARCHAR) AS line_item_availability_zone,
    CAST('my-lambda-function' AS VARCHAR) AS line_item_resource_id,
    CAST(1000000.0 AS DECIMAL(18,9)) AS line_item_usage_amount,
    CAST('Requests' AS VARCHAR) AS line_item_currency_code,
    CAST(0.0000002 AS DECIMAL(18,9)) AS line_item_unblended_rate,
    CAST(0.20 AS DECIMAL(18,9)) AS line_item_unblended_cost,
    CAST(0.0000002 AS DECIMAL(18,9)) AS line_item_blended_rate,
    CAST(0.20 AS DECIMAL(18,9)) AS line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) AS line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_end_date

UNION ALL

-- ========================================================================================
-- SAMPLE S3 STORAGE DATA
-- ========================================================================================
SELECT
    CAST('s3-1234567890abcdef0' AS VARCHAR) AS identity_line_item_id,
    CAST('20240101-20240201' AS VARCHAR) AS billing_period,
    CAST('121490076910' AS VARCHAR) AS line_item_usage_account_id,
    CAST('121490076910' AS VARCHAR) AS bill_payer_account_id,
    CAST('AmazonS3' AS VARCHAR) AS line_item_product_code,
    CAST('Storage' AS VARCHAR) AS line_item_usage_type,
    CAST('StandardStorage' AS VARCHAR) AS line_item_operation,
    CAST('us-east-1' AS VARCHAR) AS line_item_availability_zone,
    CAST('my-bucket' AS VARCHAR) AS line_item_resource_id,
    CAST(100.0 AS DECIMAL(18,9)) AS line_item_usage_amount,
    CAST('GB' AS VARCHAR) AS line_item_currency_code,
    CAST(0.023 AS DECIMAL(18,9)) AS line_item_unblended_rate,
    CAST(2.30 AS DECIMAL(18,9)) AS line_item_unblended_cost,
    CAST(0.023 AS DECIMAL(18,9)) AS line_item_blended_rate,
    CAST(2.30 AS DECIMAL(18,9)) AS line_item_blended_cost,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS line_item_usage_start_date,
    CAST('2024-01-02T00:00:00Z' AS VARCHAR) AS line_item_usage_end_date,
    CAST('2024-01-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_start_date,
    CAST('2024-02-01T00:00:00Z' AS VARCHAR) AS bill_billing_period_end_date;

-- ========================================================================================
-- VERIFICATION QUERIES - Run these after creating the table
-- ========================================================================================

-- Query 1: Total cost overview
SELECT
    SUM(line_item_blended_cost) AS total_monthly_cost,
    COUNT(DISTINCT line_item_resource_id) AS active_resources,
    COUNT(DISTINCT line_item_product_code) AS services_used
FROM billing-dashboard_dev_billing.cur_report_sample;

-- Query 2: Cost by service (Top 10)
SELECT
    line_item_product_code,
    SUM(line_item_blended_cost) AS total_cost,
    COUNT(*) AS billing_lines
FROM billing-dashboard_dev_billing.cur_report_sample
GROUP BY line_item_product_code
ORDER BY total_cost DESC
LIMIT 10;

-- Query 3: Resources by service
SELECT
    line_item_product_code AS service,
    COUNT(DISTINCT line_item_resource_id) AS resource_count,
    SUM(line_item_blended_cost) AS total_cost
FROM billing-dashboard_dev_billing.cur_report_sample
WHERE line_item_resource_id IS NOT NULL
GROUP BY line_item_product_code
ORDER BY resource_count DESC;

-- Query 4: Cost efficiency metrics
SELECT
    COUNT(DISTINCT line_item_usage_account_id) AS accounts_count,
    COUNT(DISTINCT line_item_product_code) AS services_count,
    COUNT(DISTINCT line_item_resource_id) AS resources_count,
    AVG(line_item_blended_cost) AS avg_cost_per_line,
    SUM(line_item_blended_cost) AS total_cost
FROM billing-dashboard_dev_billing.cur_report_sample;

-- ========================================================================================
-- HOW TO USE THIS SAMPLE DATA
-- ========================================================================================

/*
INSTRUCCIONES PARA USAR LOS DATOS DE EJEMPLO:

1. ABRIR AMAZON ATHENA:
   - Ir a AWS Console > Athena
   - Seleccionar database: billing-dashboard_dev_billing
   - Asegurarse que el resultado vaya a: s3://billing-dashboard-dev-billing-csvs/athena-results/

2. EJECUTAR LA CREACIÓN DE TABLA:
   - Copiar y pegar todo el CREATE TABLE statement arriba
   - Ejecutar la query (puede tomar unos segundos)

3. VERIFICAR QUE FUNCIONA:
   - Ejecutar las "VERIFICATION QUERIES" para confirmar que los datos están bien

4. IMPORTAR DASHBOARD EN GRAFANA:
   - Abrir Grafana (URL disponible en terraform output)
   - Ir a Dashboards > Import
   - Subir el archivo: examples/finops-dashboard-athena.json
   - Seleccionar Athena como data source
   - Cambiar las queries para usar 'cur_report_sample' en lugar de 'cur_report'

5. DISFRUTAR EL DASHBOARD:
   - El dashboard mostrará métricas realistas de costos y recursos
   - Incluye contadores de EC2, RDS, Lambda, etc.
   - KPIs de FinOps para análisis de eficiencia

NOTAS IMPORTANTES:
- Esta tabla es solo para TESTING mientras llegan los datos reales del CUR
- Una vez que llegue el CUR real, puedes eliminar esta tabla de ejemplo
- Los precios están basados en tarifas reales de AWS (enero 2024)
- Los datos incluyen ejemplos de EC2, RDS, Lambda y S3

FINOPS METRICS INCLUDED:
✅ Cost by Service & Account
✅ Resource Inventory Counts
✅ Cost Efficiency KPIs
✅ Idle Resource Detection
✅ Multi-service Analysis
*/

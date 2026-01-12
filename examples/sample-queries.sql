-- ========================================================================================
-- COST AND USAGE REPORT (CUR) - QUERIES DE ANÃLISIS PARA FINOPS
-- Base de datos: billing-dashboard_dev_billing
-- Tabla: cur_report
-- ========================================================================================

-- ========================================================================================
-- 1. TOTALES GENERALES DE COSTO
-- ========================================================================================

-- Costo total del mes actual
SELECT
    SUM(line_item_blended_cost) as costo_total,
    COUNT(*) as total_registros
FROM cur_report
WHERE billing_period = (
    SELECT MAX(billing_period)
    FROM cur_report
);

-- ========================================================================================
-- 2. ANÃLISIS POR CUENTA (USAGE ACCOUNT)
-- ========================================================================================

-- Costo total por cuenta que generÃ³ el uso
SELECT
    line_item_usage_account_id,
    bill_payer_account_id,
    SUM(line_item_blended_cost) as costo_total,
    COUNT(*) as total_registros
FROM cur_report
WHERE billing_period = (
    SELECT MAX(billing_period)
    FROM cur_report
)
GROUP BY line_item_usage_account_id, bill_payer_account_id
ORDER BY costo_total DESC;

-- ========================================================================================
-- 3. ANÃLISIS POR SERVICIO (SERVICE/PRODUCT)
-- ========================================================================================

-- Top 10 servicios mÃ¡s costosos del mes actual
SELECT
    line_item_product_code,
    line_item_usage_type,
    SUM(line_item_blended_cost) as costo_total,
    COUNT(*) as total_registros
FROM cur_report
WHERE billing_period = (
    SELECT MAX(billing_period)
    FROM cur_report
)
GROUP BY line_item_product_code, line_item_usage_type
ORDER BY costo_total DESC
LIMIT 10;


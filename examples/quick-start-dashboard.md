# 🚀 Quick Start: FinOps Dashboard con Datos de Ejemplo

Esta guía te lleva de 0 a dashboard funcionando en menos de 10 minutos.

## 📋 Paso 1: Preparar Athena

### 1.1 Abrir Amazon Athena
- Ve a AWS Console → Amazon Athena
- Asegúrate de estar en la región correcta (us-east-1)

### 1.2 Configurar Query Result Location
- Settings → Query result location
- Establecer: `s3://billing-dashboard-dev-billing-csvs/athena-results/`

## 📊 Paso 2: Crear Datos de Ejemplo

### Opción A: Método Simple (Recomendado)
```sql
-- Copia y pega TODO esto en Athena y ejecuta:

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

INSERT INTO cur_report_sample VALUES
('i-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonEC2', 'BoxUsage:t2.micro', 'RunInstances', 'us-east-1a', 'i-1234567890abcdef0',
 730.0, 'Hrs', 0.0116, 8.47, 0.0116, 8.47,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

('db-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonRDS', 'InstanceUsage:db.t3.micro', 'CreateDBInstance', 'us-east-1a', 'my-database',
 730.0, 'Hrs', 0.017, 12.41, 0.017, 12.41,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

('lambda-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AWSLambda', 'Request', 'Invoke', 'us-east-1', 'my-lambda-function',
 1000000.0, 'Requests', 0.0000002, 0.20, 0.0000002, 0.20,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z'),

('s3-1234567890abcdef0', '20240101-20240201', '121490076910', '121490076910',
 'AmazonS3', 'Storage', 'StandardStorage', 'us-east-1', 'my-bucket',
 100.0, 'GB', 0.023, 2.30, 0.023, 2.30,
 '2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z', '2024-01-01T00:00:00Z', '2024-02-01T00:00:00Z');
```

### 1.3 Verificar Datos
Ejecuta estas queries para confirmar que funciona:

```sql
-- Verificar total de filas
SELECT COUNT(*) FROM cur_report_sample;

-- Verificar costo total
SELECT SUM(line_item_blended_cost) as total_cost FROM cur_report_sample;

-- Verificar servicios
SELECT line_item_product_code, SUM(line_item_blended_cost) as cost
FROM cur_report_sample
GROUP BY line_item_product_code
ORDER BY cost DESC;
```

## 📈 Paso 3: Configurar Grafana

### 3.1 Obtener URL de Grafana
```bash
terraform output grafana_url
# Ejemplo: http://34.195.80.241
```

### 3.2 Agregar Data Source Athena
1. Abrir Grafana en el navegador
2. **Configuration** → **Data Sources** → **Add data source**
3. Buscar y seleccionar **Amazon Athena**
4. Configurar:
   ```
   Name: AWS CUR Athena
   Database: billing-dashboard_dev_billing
   Workgroup: primary
   Region: us-east-1
   Authentication: AWS SDK Default
   ```
5. **Save & Test** (debe decir "Success")

## 📊 Paso 4: Importar Dashboard

1. **Dashboards** → **Import**
2. **Upload JSON file**: `examples/finops-dashboard-athena.json`
3. Seleccionar **AWS CUR Athena** como data source
4. **Import**

## 🎯 Paso 5: Ver el Dashboard

¡Listo! Tu dashboard de FinOps debería mostrar:

### 📊 Paneles Principales:
- **$23.38** - Costo total mensual
- **4** - Recursos activos
- **4** - Servicios utilizados
- **EC2, RDS, Lambda, S3** - Servicios más costosos
- **Contadores por servicio** - Recursos específicos

### 🎨 Características:
- ✅ Métricas de costo en tiempo real
- ✅ Contadores de recursos (EC2, RDS, Lambda)
- ✅ KPIs de eficiencia de FinOps
- ✅ Visualizaciones profesionales
- ✅ Actualización automática

## 🛠️ Troubleshooting

### ❌ "No data"
- Verifica que la tabla `cur_report_sample` existe en Athena
- Confirma que el data source de Grafana está configurado correctamente

### ❌ "Query failed"
- Revisa que estés usando la base de datos correcta
- Verifica las queries en Athena primero

### ❌ "Cannot connect to Athena"
- Verifica las credenciales AWS en Grafana
- Asegúrate de que la región sea correcta (us-east-1)

## 🚀 Próximos Pasos

1. **Esperar datos reales**: Cuando llegue el CUR, cambiará automáticamente a `cur_report`
2. **Personalizar**: Agrega más paneles según tus necesidades
3. **Alertas**: Configura notificaciones para costos altos
4. **Reportes**: Programa envíos automáticos

---

**¡Ya tienes un dashboard de FinOps completamente funcional!** 🎉📊

¿Necesitas ayuda con algún paso específico?

# FinOps Dashboard Setup Guide

Esta guía explica cómo configurar y usar los dashboards de Grafana para análisis de costos y recursos de AWS siguiendo la metodología FinOps.

## 📊 Dashboards Disponibles

### 1. `finops-dashboard.json`
- **Tipo**: Dashboard de ejemplo con métricas simuladas
- **Propósito**: Demostración de visualizaciones FinOps
- **Fuente de datos**: Métricas de ejemplo (no requiere configuración)

### 2. `finops-dashboard-athena.json`
- **Tipo**: Dashboard con datos reales de CUR
- **Propósito**: Análisis completo de costos y recursos
- **Fuente de datos**: Amazon Athena (requiere configuración)

## 🚀 Configuración del Dashboard

### Paso 1: Acceder a Grafana

```bash
# Obtener la URL de Grafana
terraform output grafana_url

# Obtener la clave SSH privada
terraform output grafana_ssh_private_key > grafana-key.pem
chmod 600 grafana-key.pem

# Conectarse por SSH (opcional)
ssh -i grafana-key.pem ec2-user@<GRAFANA_IP>
```

### Paso 2: Configurar Athena como Data Source

1. **Abrir Grafana** en tu navegador: `http://<GRAFANA_IP>`
2. **Credenciales por defecto**:
   - Usuario: `admin`
   - Contraseña: `admin123`

3. **Agregar Data Source**:
   - Ir a **Configuration** → **Data Sources**
   - Click en **Add data source**
   - Buscar y seleccionar **Amazon Athena**

4. **Configurar Athena**:
   ```
   Name: AWS CUR Athena
   Database: billing-dashboard_dev_billing
   Workgroup: primary
   Region: us-east-1
   Authentication: AWS SDK Default
   ```

### Paso 3: Importar el Dashboard

1. **Ir a Dashboards** → **Import**
2. **Cargar el archivo JSON**: `examples/finops-dashboard-athena.json`
3. **Seleccionar Data Source**: "AWS CUR Athena"
4. **Importar**

## 📈 Paneles del Dashboard

### 1. Current Month Total Cost
- **Métrica**: Costo total del mes actual
- **Unidad**: USD
- **Umbrales**: Verde (< $1000), Amarillo ($1000-$5000), Rojo (>$5000)

### 2. Active Resources Count
- **Métrica**: Número total de recursos activos
- **Incluye**: EC2, RDS, Lambda, S3, etc.
- **Excluye**: Recursos sin identificador

### 3. Top Cost Services
- **Visualización**: Gráfico de barras
- **Métrica**: Costo por servicio (Top 10)
- **Orden**: Descendente por costo

### 4. Cost by Account
- **Visualización**: Gráfico circular
- **Métrica**: Distribución de costos por cuenta AWS
- **Útil para**: Chargeback y accountability

### 5. EC2 Instance Cost Analysis
- **Vista detallada**: Costos por instancia EC2
- **Métricas**: Costo total, horas de uso
- **Ayuda a identificar**: Instancias over/under provisioned

### 6. RDS Database Cost Analysis
- **Vista detallada**: Costos por base de datos RDS
- **Métricas**: Costo total, horas de uso
- **Útil para**: Optimización de bases de datos

### 7. Lambda Functions Cost
- **Análisis serverless**: Costos por función Lambda
- **Métricas**: Costo total, número de requests
- **Ayuda a optimizar**: Arquitecturas serverless

### 8. Cost Efficiency Metrics
- **KPIs principales**:
  - Número de cuentas activas
  - Número de servicios utilizados
  - Número total de recursos
  - Costo promedio por línea

### 9. Unused/Idle Resources
- **Detección automática**: Recursos con bajo uso
- **Métrica**: Recursos con usage_amount < 1
- **Ayuda a**: Identificar candidatos para optimización

## 🎯 KPIs de FinOps Incluidos

### Métricas de Costo
- **Total Cost**: Costo total mensual
- **Cost by Service**: Distribución por servicio
- **Cost by Account**: Accountability por cuenta
- **Cost Trends**: Tendencias temporales

### Métricas de Recursos
- **Active Resources**: Conteo total de recursos
- **Resource Utilization**: Eficiencia de uso
- **Idle Resources**: Recursos sin utilizar
- **Service Distribution**: Distribución por tipo de servicio

### Métricas de Eficiencia
- **Cost per Resource**: Costo promedio por recurso
- **Service Diversity**: Número de servicios utilizados
- **Account Coverage**: Alcance multi-cuenta

## 🔧 Configuración Avanzada

### Variables de Template
```sql
-- Para filtrar por período específico
WHERE billing_period = '20240101-20240201'

-- Para filtrar por servicio específico
AND line_item_product_code = 'AmazonEC2'

-- Para filtrar por cuenta específica
AND line_item_usage_account_id = '123456789012'
```

### Consultas Personalizadas
```sql
-- Costo diario por servicio (últimos 30 días)
SELECT
    DATE_TRUNC('day', DATE_PARSE(line_item_usage_start_date, '%Y-%m-%dT%H:%i:%sZ')) as fecha,
    line_item_product_code,
    SUM(line_item_blended_cost) as costo_diario
FROM cur_report
WHERE DATE_PARSE(line_item_usage_start_date, '%Y-%m-%dT%H:%i:%sZ') >= CURRENT_DATE - INTERVAL '30' DAY
GROUP BY DATE_TRUNC('day', DATE_PARSE(line_item_usage_start_date, '%Y-%m-%dT%H:%i:%sZ')), line_item_product_code
ORDER BY fecha, costo_diario DESC;
```

## 📋 Próximos Pasos

### 1. Datos Reales
- Esperar que CUR genere los primeros archivos
- Verificar en S3: `s3://billing-dashboard-dev-billing-csvs/cur-reports-v2/`
- El crawler se ejecutará automáticamente

### 2. Personalización
- Agregar más paneles según necesidades específicas
- Crear dashboards por equipo/departamento
- Configurar alertas automáticas

### 3. Automatización
- Configurar reportes automáticos
- Integrar con herramientas de FinOps
- Crear dashboards ejecutivos

## 🆘 Solución de Problemas

### Dashboard no carga datos
1. Verificar conexión a Athena
2. Revisar permisos IAM
3. Confirmar que existen datos en la tabla CUR

### Consultas fallan
1. Verificar sintaxis SQL
2. Confirmar nombres de columnas
3. Revisar permisos de Athena

### Datos no aparecen
1. Esperar que CUR genere archivos
2. Verificar configuración del crawler
3. Revisar logs de Glue

## 📚 Recursos Adicionales

- [AWS CUR Documentation](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html)
- [Athena Best Practices](https://docs.aws.amazon.com/athena/latest/ug/best-practices.html)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [FinOps Framework](https://www.finops.org/framework/)

---

**Dashboard creado para demostrar análisis cuantitativo de costos y recursos siguiendo principios FinOps** 💰📊

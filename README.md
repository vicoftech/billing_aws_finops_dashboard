# AWS Cost and Usage Report (CUR) Dashboard - FinOps Solution

Una soluciÃ³n completa de FinOps para monitorear costos de AWS usando Cost and Usage Reports, Athena y Grafana.

## ðŸš€ CaracterÃ­sticas

- **Cost and Usage Report (CUR)** configurado para entrega diaria
- **AWS Glue Crawler** para catalogar datos automÃ¡ticamente
- **Amazon Athena** para consultas SQL optimizadas
- **EC2 con Grafana** auto-hospedado para visualizaciones
- **Queries SQL predefinidas** para anÃ¡lisis de costos
- **Infraestructura como cÃ³digo** con Terraform
- **Scripts de automatizaciÃ³n** para despliegue y mantenimiento

## ðŸ“‹ Prerrequisitos

- AWS CLI configurado con credenciales vÃ¡lidas
- Terraform >= 1.0
- Cuenta AWS con permisos para crear recursos
- (Opcional) OrganizaciÃ³n AWS para anÃ¡lisis multi-cuenta

## ðŸ—ï¸ Arquitectura

`
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   CUR Report    â”‚ -> â”‚   S3 Bucket     â”‚ -> â”‚  Glue Crawler   â”‚
â”‚   (Diario)      â”‚    â”‚   (Parquet)     â”‚    â”‚  (AutomÃ¡tico)   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                                        â”‚
                                                        â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   Glue Catalog  â”‚ -> â”‚   Athena        â”‚ -> â”‚   EC2 + Grafana â”‚
â”‚   Database      â”‚    â”‚   Queries       â”‚    â”‚   Dashboard     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
`

## ðŸš€ Despliegue RÃ¡pido

### 1. Clonar y configurar
`ash
git clone <repository-url>
cd billing-dashboard
`

### 2. Configurar credenciales AWS
`ash
# Ejecutar script de configuraciÃ³n
./scripts/fix-aws-creds.ps1
`

### 3. Desplegar infraestructura
`ash
cd infrastructure
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars" -auto-approve
`

### 4. Verificar despliegue
`ash
terraform output
`

## ðŸ“Š Uso de las Queries

### Base de datos Athena
- **Database:** illing-dashboard_dev_billing
- **Table:** cur_report

### Queries principales
Ver examples/sample-queries.sql para queries completas de:
- Costos totales por cuenta
- AnÃ¡lisis por servicio
- Tendencias diarias
- Costos por regiÃ³n
- AnÃ¡lisis de Savings Plans

### Query bÃ¡sica de ejemplo
`sql
SELECT
    line_item_usage_account_id,
    bill_payer_account_id,
    SUM(line_item_blended_cost) as costo_total
FROM cur_report
GROUP BY line_item_usage_account_id, bill_payer_account_id
ORDER BY costo_total DESC;
`

## ðŸ”§ ConfiguraciÃ³n de Entornos

### Variables por entorno
- dev.tfvars - Desarrollo
- staging.tfvars - Staging
- prod.tfvars - ProducciÃ³n

### Perfiles AWS
- sj_dev - Desarrollo
- sj_test - Testing
- sj_prod - ProducciÃ³n

## ðŸ“ˆ Dashboard Grafana

### Acceso
`ash
terraform output grafana_url
terraform output grafana_ssh_private_key
`

### Puerto
- **HTTP:** Puerto 80 (accesible desde internet)
- **SSH:** Para administraciÃ³n

## ðŸ› ï¸ Scripts de Utilidad

### Workspace Helper
`ash
# PowerShell
./scripts/workspace-helper.ps1

# Bash
./scripts/workspace-helper.sh
`

### DiagnÃ³stico AWS
`ash
./scripts/diagnose-aws-creds.ps1
./scripts/fix-aws-creds.ps1
`

## ðŸ“ Estructura del Proyecto

`
billing-dashboard/
â”œâ”€â”€ infrastructure/          # ConfiguraciÃ³n Terraform
â”‚   â”œâ”€â”€ main.tf             # Recursos principales
â”‚   â”œâ”€â”€ variables.tf        # Variables de configuraciÃ³n
â”‚   â”œâ”€â”€ outputs.tf          # Salidas del despliegue
â”‚   â””â”€â”€ *.tfvars           # ConfiguraciÃ³n por entorno
â”œâ”€â”€ examples/               # Ejemplos y documentaciÃ³n
â”‚   â”œâ”€â”€ sample-queries.sql  # Queries SQL para Athena
â”‚   â””â”€â”€ environment-configs.tfvars
â”œâ”€â”€ scripts/                # Scripts de automatizaciÃ³n
â”‚   â”œâ”€â”€ workspace-helper.*  # Helpers de Terraform
â”‚   â””â”€â”€ *-aws-creds.*       # Utilidades de credenciales
â”œâ”€â”€ docs/                   # DocumentaciÃ³n detallada
â””â”€â”€ lambda/                 # CÃ³digo de funciones Lambda
`

## ðŸ”’ Seguridad

- **Credenciales:** Nunca commitar claves AWS
- **Permisos mÃ­nimos:** Principio de menor privilegio
- **Secrets:** Usar AWS Secrets Manager para credenciales sensibles
- **Redes:** Recursos en subnets privadas donde aplique

## ðŸš¨ Troubleshooting

### Error de parsing de fechas
`
GENERIC_INTERNAL_ERROR: Text '2024-01-01' could not be parsed at index 4
`
**SoluciÃ³n:** Esperar nuevos datos CUR o cambiar prefijo S3 (ya solucionado)

### Credenciales expiradas
`ash
./scripts/fix-aws-creds.ps1
`

### Problemas de permisos
Ver docs/IAM_PERMISSIONS.md para permisos requeridos.

## ðŸ¤ ContribuciÃ³n

1. Fork el proyecto
2. Crear rama feature (git checkout -b feature/AmazingFeature)
3. Commit cambios (git commit -m 'Add AmazingFeature')
4. Push a la rama (git push origin feature/AmazingFeature)
5. Abrir Pull Request

## ðŸ“ Licencia

Este proyecto estÃ¡ bajo la Licencia MIT - ver el archivo LICENSE para detalles.

## ðŸ“ž Soporte

Para soporte tÃ©cnico:
- Revisar docs/TROUBLESHOOTING.md
- Verificar issues en GitHub
- Contactar al equipo de FinOps

---

**FinOps Team** - Optimizando costos en la nube â˜ï¸ðŸ’°

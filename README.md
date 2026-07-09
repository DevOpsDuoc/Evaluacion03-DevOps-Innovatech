# Evaluación ETF — DevOps Innovatech 

Proyecto de evaluación para el ramo de Introducción a DevOps (DuocUC). Despliega un sistema de gestión de **ventas y despachos** ("Innovatech") como un stack de microservicios contenerizado en **Amazon EKS**, con infraestructura como código en **Terraform** y entrega continua vía **GitHub Actions**.

## Arquitectura

El sistema modela el flujo *venta → despacho → cierre* con tres componentes desplegados como microservicios independientes, más una base de datos MySQL:

| Servicio | Ruta | Stack | Puerto |
|---|---|---|---|
| Frontend (SPA) | `app-k8s/front-despacho` | React 18 + Vite, Tailwind, Axios, SweetAlert2, servido por Nginx | 80 |
| API de Ventas | `app-k8s/back-ventas-springboot/api-rest-ventas` | Spring Boot 3.4.4, Spring Data JPA, springdoc-openapi | 8080 |
| API de Despachos | `app-k8s/back-despachos-springboot/api-rest-despacho` | Spring Boot 3.4.4, Spring Data JPA, springdoc-openapi | 8081 |
| Base de datos | `mysql-db` (imagen propia en ECR) | MySQL | 3306 |

Todos los recursos de Kubernetes viven en el namespace `innovatech`. Cada servicio backend expone Swagger UI en `/swagger-ui.html` y documentación OpenAPI en `/v3/api-docs`.

## Infraestructura (Terraform)

La infraestructura AWS está dividida en dos raíces Terraform independientes bajo `terraform/`:

- **`terraform/cluster`** — Provisiona VPC, subnets públicas/privadas, security groups, el clúster **EKS** (`tienda-eks`, K8s 1.30) y los repositorios **ECR**. Es autocontenido: no depende de que el clúster ya exista.
- **`terraform/addons`** — Instala add-ons de Kubernetes sobre el clúster creado por `cluster/` (leyendo su estado remoto vía `terraform_remote_state`): el **AWS Load Balancer Controller** (Helm) y el `Secret` con las credenciales AWS que ese controlador necesita.

Ambas raíces están pensadas para **AWS Academy Learner Lab**:
- Usan el rol preexistente `LabRole` para el clúster y los nodos (Academy no permite crear roles IAM).
- Como no hay IRSA disponible, el LBC recibe las credenciales de la sesión de Academy (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) inyectadas como variables de entorno vía un `kubernetes_secret`.
- Un bloque `check` valida en cada `plan`/`apply` que esas tres variables estén seteadas, para evitar aplicar sin credenciales.

Módulos reutilizables en `terraform/modules/`: `network`, `security_groups`, `eks`, `ecr`.

### Uso

```bash
# 1. Cargar credenciales de AWS Academy en el shell
source terraform/export_vars.sh

# 2. Provisionar VPC, EKS y ECR
cd terraform/cluster
terraform init
terraform apply

# 3. Instalar los add-ons (LBC) sobre el clúster ya creado
cd ../addons
terraform init
terraform apply
```

Tras el `apply` de `cluster/`, conéctate al clúster con:

```bash
aws eks update-kubeconfig --region us-east-1 --name tienda-eks
```

## Despliegue en Kubernetes

Los manifiestos viven en `app-k8s/k8s/` (namespace, `Secret` de MySQL, Deployments/Services de los tres microservicios, y HPA). El `Makefile` en `app-k8s/` automatiza build/push a ECR y el despliegue completo:

```bash
# Build + tag + push de las 3 imágenes a ECR (requiere Docker y AWS CLI)
make account=<AWS_ACCOUNT_ID> login
make account=<AWS_ACCOUNT_ID> publish-all

# Desplegar todo el stack en EKS (namespace, MySQL, backends, frontend, HPA)
make deploy

# Ver el estado del namespace
make status

# Eliminar todo el stack
make undeploy
```

Autoescalado configurado vía `HorizontalPodAutoscaler` (métricas de CPU): Ventas y Despachos escalan de 2 a 8 réplicas al 70% de utilización; el frontend de 2 a 6 réplicas al 60%.

## CI/CD

`.github/workflows/cicd.yaml` define un pipeline que en cada push a `main`:
1. Se autentica en AWS y en ECR.
2. Construye y publica las imágenes de frontend, API de Ventas y API de Despachos (tag = SHA corto del commit).
3. Configura `kubectl` contra el clúster EKS.
4. Aplica los manifiestos base (namespace, MySQL) y actualiza cada Deployment con `kubectl set image`, esperando el rollout.
5. Aplica el HPA unificado y muestra el estado final de pods/servicios.

Requiere los siguientes secrets del repositorio: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `EKS_CLUSTER_NAME`, `EKS_NAMESPACE`.

## Desarrollo local

**Frontend**
```bash
cd app-k8s/front-despacho
npm install
npm run dev
```

**Backends** (requieren JDK 17 y variables `DB_ENDPOINT`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`):
```bash
cd app-k8s/back-ventas-springboot/api-rest-ventas
./mvnw spring-boot:run
```

## Estado del proyecto

Existe un `FINDINGS.md` con una revisión estática detallada del código (arquitectura, endpoints, y una lista de bugs e inconsistencias pendientes: URLs de frontend hardcodeadas a IPs LAN, perfiles de test no externalizados, mismatch de nombres de campo `despachado`/`entregado`, falta de `@Valid` en Despachos, CORS duplicado, entre otros). Revísalo antes de dar el proyecto por productivo.

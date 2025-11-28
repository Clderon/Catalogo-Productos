# Catálogo de Productos API

Sistema de gestión y consulta de productos y categorías diseñado como microservicio cloud-native, orquestado con Kubernetes y aprovisionado mediante Terraform.

## Tabla de Contenidos

- [Descripción](#descripción)
- [Tecnologías](#tecnologías)
- [Arquitectura](#arquitectura)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Requisitos Previos](#requisitos-previos)
- [Instalación y Despliegue](#instalación-y-despliegue)
- [Variables de Configuración](#variables-de-configuración)
- [Endpoints de la API](#endpoints-de-la-api)
- [Estado del Proyecto](#estado-del-proyecto)
- [Próximos Pasos](#próximos-pasos)
- [Comandos de Debugging](#comandos-de-debugging)
- [Mejoras Sugeridas](#mejoras-sugeridas)

## Descripción

Sistema en línea para consultar y gestionar productos y categorías. Forma parte de una arquitectura desplegada en Kubernetes y aprovisionada con Terraform. Utiliza Docker para contenerización, MySQL como base de datos y JWT para autenticación.

## Tecnologías

| Componente | Tecnología | Rol |
|------------|------------|-----|
| Backend | Node.js + Express | API RESTful para lógica de negocio |
| Base de Datos | MySQL 8.0 | Almacenamiento persistente de datos |
| Contenerización | Docker | Empaquetado de la aplicación |
| Orquestación | Kubernetes | Despliegue en alta disponibilidad y balanceo de carga |
| IaC | Terraform | Aprovisionamiento declarativo de recursos |
| Autenticación | JWT | Protección de rutas (implementación pendiente) |

## Arquitectura

```
Cliente
   |
   v
LoadBalancer Service (Kubernetes)
   |
   +-- API Pod (Replica 1)
   |
   +-- API Pod (Replica 2)
   |
   v
MySQL Pod
```

## Estructura del Proyecto

```
Catalogo-Productos/
├── api/
│   ├── Dockerfile          # Definición de la imagen Docker
│   ├── package.json        # Dependencias del proyecto Node.js
│   └── src/                # Código de la aplicación
│       └── app.js          # PENDIENTE: Lógica del servidor Express
│
├── database/
│   └── init.sql            # Script de creación de DB y tablas con FK
│
├── kubernetes/             # Manifiestos K8s (alternativa manual)
│   ├── deployment.yaml     # Deployment con 2 réplicas
│   ├── secret.yaml         # Credenciales (DB y JWT)
│   └── service.yaml        # Service LoadBalancer
│
└── terraform/              # Infraestructura como Código
    ├── main.tf             # Recursos principales de Kubernetes
    ├── variables.tf        # Variables de configuración
    ├── providers.tf        # Configuración del proveedor
    └── outputs.tf          # Valores de salida opcionales
```

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- Docker (v20.10 o superior)
- Kubernetes (cluster local con Minikube o Docker Desktop)
- kubectl (v1.24 o superior)
- Terraform (v1.0 o superior)
- Node.js (v18 o superior) para desarrollo local

Verificar instalación:

```bash
docker --version
kubectl version --client
terraform --version
node --version
```

## Instalación y Despliegue

### Opción 1: Despliegue con Terraform (Recomendado)

#### Paso 1: Construir la imagen Docker

Desde el directorio raíz del proyecto:

```bash
docker build -t product-api:1.0 ./api
```

#### Paso 2: Inicializar Terraform

```bash
cd terraform
terraform init
```

#### Paso 3: Revisar el plan de despliegue

```bash
terraform plan
```

#### Paso 4: Aplicar la infraestructura

```bash
terraform apply -auto-approve
```

#### Paso 5: Obtener la URL del servicio

Para Minikube:

```bash
minikube service product-api-service --url -n catalogo
```

Para otros clústeres:

```bash
kubectl get svc product-api-service -n catalogo
```

### Opción 2: Despliegue Manual con kubectl

```bash
# Crear namespace
kubectl create namespace catalogo

# Aplicar manifiestos
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Verificar despliegue
kubectl get pods -n catalogo
kubectl get svc -n catalogo
```

## Variables de Configuración

Variables principales en `terraform/variables.tf`:

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| namespace | Namespace de Kubernetes | `catalogo` |
| api_image | Imagen Docker del API | `product-api:1.0` |
| replicas | Número de réplicas del Deployment | `2` |

Para personalizar valores, crear archivo `terraform.tfvars`:

```hcl
namespace = "mi-catalogo"
api_image = "product-api:2.0"
replicas  = 3
```

## Endpoints de la API

NOTA: Los endpoints están planificados pero pendientes de implementación en `api/src/app.js`.

### Productos

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/api/productos` | Listar todos los productos | No |
| GET | `/api/productos/:id` | Obtener producto por ID | No |
| POST | `/api/productos` | Crear nuevo producto | JWT requerido |
| PUT | `/api/productos/:id` | Actualizar producto | JWT requerido |
| DELETE | `/api/productos/:id` | Eliminar producto | JWT requerido |

### Categorías

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/api/categorias` | Listar todas las categorías | No |
| GET | `/api/categorias/:id` | Obtener categoría por ID | No |
| POST | `/api/categorias` | Crear nueva categoría | JWT requerido |
| PUT | `/api/categorias/:id` | Actualizar categoría | JWT requerido |
| DELETE | `/api/categorias/:id` | Eliminar categoría | JWT requerido |

### Ejemplos de Uso

Listar productos:

```bash
curl http://localhost:3000/api/productos
```

Crear producto (requiere JWT):

```bash
curl -X POST http://localhost:3000/api/productos \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laptop Dell XPS",
    "precio": 1299.99,
    "categoria_id": 1
  }'
```

## Estado del Proyecto

| Requerimiento | Estado | Detalle | Prioridad |
|---------------|--------|---------|-----------|
| Esquema de Base de Datos | COMPLETO | `database/init.sql` define tablas y FK | - |
| Autenticación JWT | PENDIENTE | Secret configurado, falta lógica en `app.js` | ALTA |
| Alta Disponibilidad | COMPLETO | Deployment con 2 réplicas y LoadBalancer | - |
| Infraestructura IaC | PARCIAL | Terraform funcional, falta PVC para MySQL | MEDIA |
| Implementación API | PENDIENTE | Falta crear `api/src/app.js` completo | ALTA |
| Persistencia de Datos | PENDIENTE | MySQL sin PVC, datos se pierden al reiniciar | MEDIA |
| Gestión de Secrets | PENDIENTE | Credenciales hardcodeadas, usar tfvars | MEDIA |
| Documentación API | PENDIENTE | Añadir OpenAPI/Swagger | BAJA |

## Próximos Pasos

### 1. Implementar el archivo `api/src/app.js`

El archivo debe incluir:

- Servidor Express en puerto 3000
- Conexión a MySQL usando variables de entorno:
  - `DB_HOST`
  - `DB_USER`
  - `DB_PASSWORD`
  - `DB_PORT`
  - `DB_NAME`
- Rutas públicas de lectura (GET)
- Middleware de autenticación JWT para rutas protegidas (POST/PUT/DELETE)
- Validación de header `Authorization: Bearer <token>`

### 2. Añadir Persistencia a MySQL

Modificar `terraform/main.tf` para incluir:

```hcl
resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
```

### 3. Externalizar Valores Sensibles

Crear `terraform/terraform.tfvars`:

```hcl
db_password = "tu_password_seguro"
jwt_secret  = "tu_jwt_secret_seguro"
```

Actualizar `variables.tf` y `main.tf` para usar estas variables.

### 4. Añadir Endpoint de Autenticación

Implementar ruta `/api/auth/login` que:
- Valide credenciales de usuario
- Genere y retorne token JWT
- Configure tiempo de expiración del token

## Comandos de Debugging

### Ver estado de recursos

```bash
# Ver todos los pods
kubectl get pods -n catalogo

# Ver servicios
kubectl get svc -n catalogo

# Ver deployments
kubectl get deployments -n catalogo

# Describir un pod específico
kubectl describe pod <POD_NAME> -n catalogo
```

### Ver logs

```bash
# Logs del API en tiempo real
kubectl logs -f deployment/product-api -n catalogo

# Logs de MySQL
kubectl logs -f deployment/mysql -n catalogo

# Logs de un pod específico
kubectl logs <POD_NAME> -n catalogo

# Logs anteriores (si el pod crasheó)
kubectl logs <POD_NAME> -n catalogo --previous
```

### Acceder a los contenedores

```bash
# Shell en el pod de MySQL
kubectl exec -it deployment/mysql -n catalogo -- bash

# Conectarse directamente a MySQL
kubectl exec -it deployment/mysql -n catalogo -- mysql -u root -p

# Shell en el pod del API
kubectl exec -it deployment/product-api -n catalogo -- sh
```

### Port forwarding para pruebas locales

```bash
# Acceder al API localmente
kubectl port-forward svc/product-api-service 3000:80 -n catalogo

# Acceder a MySQL localmente
kubectl port-forward svc/mysql 3306:3306 -n catalogo
```

### Ver eventos del namespace

```bash
kubectl get events -n catalogo --sort-by='.lastTimestamp'
```

### Reiniciar deployments

```bash
# Reiniciar el API
kubectl rollout restart deployment/product-api -n catalogo

# Reiniciar MySQL
kubectl rollout restart deployment/mysql -n catalogo
```

## Mejoras Sugeridas

### Seguridad

- Implementar gestión de secrets con HashiCorp Vault o Sealed Secrets
- Usar variables de entorno para credenciales en lugar de hardcodear
- Implementar rate limiting en el API
- Añadir validación de entrada en todos los endpoints
- Configurar RBAC (Role-Based Access Control) en Kubernetes

### Persistencia

- Añadir PersistentVolumeClaim para MySQL
- Configurar StorageClass apropiado
- Implementar backups automáticos de la base de datos
- Considerar StatefulSet en lugar de Deployment para MySQL

### Monitoreo y Observabilidad

- Integrar Prometheus para métricas
- Añadir Grafana para visualización
- Implementar health checks y readiness probes
- Configurar alertas para eventos críticos
- Añadir logging estructurado (ej. Winston o Bunyan)

### Testing

- Añadir tests unitarios con Jest o Mocha
- Implementar tests de integración
- Configurar CI/CD pipeline (GitHub Actions, GitLab CI)
- Añadir tests de carga con k6 o Artillery

### Documentación

- Generar documentación automática con OpenAPI/Swagger
- Añadir ejemplos de requests y responses
- Documentar códigos de error
- Crear guía de contribución
- Añadir arquitectura de decisiones (ADRs)

### Separación de Ambientes

- Crear configuraciones para dev/staging/prod
- Usar diferentes imágenes por ambiente
- Separar secrets por ambiente
- Implementar estrategias de despliegue (blue-green, canary)

## Solución de Problemas Comunes

### Pods en CrashLoopBackOff

```bash
# Ver logs del pod que falló
kubectl logs <POD_NAME> -n catalogo --previous

# Describir el pod para ver eventos
kubectl describe pod <POD_NAME> -n catalogo
```

### Servicio no accesible

```bash
# Verificar que el servicio existe
kubectl get svc -n catalogo

# Describir el servicio
kubectl describe svc product-api-service -n catalogo

# Verificar endpoints
kubectl get endpoints -n catalogo
```

### Imagen Docker no encontrada

```bash
# Listar imágenes locales
docker images | grep product-api

# Reconstruir sin caché
docker build --no-cache -t product-api:1.0 ./api

# Para Minikube, usar el daemon de Docker de Minikube
eval $(minikube docker-env)
docker build -t product-api:1.0 ./api
```

### MySQL no inicia

```bash
# Ver logs de MySQL
kubectl logs -f deployment/mysql -n catalogo

# Verificar variables de entorno
kubectl exec deployment/mysql -n catalogo -- env | grep MYSQL
```

## Licencia

Este proyecto está bajo la Licencia MIT.

## Contacto

Para preguntas o sugerencias, abre un issue en el repositorio.
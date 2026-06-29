# ==============================================================================
# Makefile — Innovatech
#
# Automates:
#   1. AWS ECR login, build, tag, and push for all 4 microservices
#   2. Full deployment & status management on Amazon EKS
# ==============================================================================

# --- Toolchain --------------------------------------------------------------
DOCKER       ?= docker
AWS          ?= aws
KUBECTL      ?= kubectl

# --- Configuration ----------------------------------------------------------
region       ?= us-east-1
tag          ?= eks-v1
NAMESPACE    := innovatech

# Repositories names defined in Amazon ECR
ECR_REPO_FRONTEND         := front-despacho
ECR_REPO_BACKEND_VENTAS   := backend-ventas
ECR_REPO_BACKEND_DESPACHOS := backend-despachos
ECR_REPO_DB               := mysql-db

# Composed ECR Registry URI
ECR_REGISTRY := $(account).dkr.ecr.$(region).amazonaws.com

.PHONY: help login build-all publish-all deploy status undeploy check-account check-docker

# --- Help Menu --------------------------------------------------------------
help:
	@echo "======================================================================"
	@echo "Innovatech DevOps Automation Tool"
	@echo "======================================================================"
	@echo "Variables:"
	@echo "  account   AWS account ID (REQUIRED for login/publish) [$(account)]"
	@echo "  tag       Image tag to apply                           [$(tag)]"
	@echo "  region    AWS region for ECR                           [$(region)]"
	@echo
	@echo "Comandos DevOps Básicos:"
	@echo "  make account=<ID> login        # Paso 1: Autenticar Docker con AWS"
	@echo "  make account=<ID> publish-all  # Paso 2: Build + Tag + Push de todas las imágenes"
	@echo "  make deploy                    # Paso 3: Desplegar todo en Kubernetes EKS"
	@echo "  make status                    # Monitorear Pods, Services y HPA en tiempo real"
	@echo "  make undeploy                  # Remover todo el stack del clúster"

# --- Tooling Checks ---------------------------------------------------------
check-docker:
	@command -v $(DOCKER) >/dev/null 2>&1 || { echo "ERROR: $(DOCKER) no está instalado."; exit 1; }
	@command -v $(AWS) >/dev/null 2>&1 || { echo "ERROR: $(AWS) CLI no está instalado."; exit 1; }

check-account:
	@if [ -z "$(account)" ]; then \
		echo "ERROR: La variable 'account' es REQUERIDA."; \
		echo "Uso: make account=637083690819 <target>"; \
		exit 1; \
	fi

# ==============================================================================
# SECCIÓN 1: AUTOMATIZACIÓN DE DOCKER & AMAZON ECR
# ==============================================================================

login: check-docker check-account
	@echo "[login] Autenticando contra $(ECR_REGISTRY)..."
	@$(AWS) ecr get-login-password --region $(region) | $(DOCKER) login --username AWS --password-stdin $(ECR_REGISTRY)
	@echo "[login] OK — Autenticación exitosa."

# Atajo Maestro para Compilar, Etiquetar y Subir todo a AWS de forma local (Si no usan GitHub Actions)
publish-all: login check-account
	@echo "[publish] Iniciando compilación local multipropósito..."
	
	# Frontend
	$(DOCKER) build -t $(ECR_REPO_FRONTEND) app-k8s/front-despacho
	$(DOCKER) tag $(ECR_REPO_FRONTEND):latest $(ECR_REGISTRY)/$(ECR_REPO_FRONTEND):$(tag)
	$(DOCKER) push $(ECR_REGISTRY)/$(ECR_REPO_FRONTEND):$(tag)
	
	# Backend Ventas (Java Spring Boot)
	$(DOCKER) build -t $(ECR_REPO_BACKEND_VENTAS) app-k8s/back-ventas-springboot/api-rest-ventas
	$(DOCKER) tag $(ECR_REPO_BACKEND_VENTAS):latest $(ECR_REGISTRY)/$(ECR_REPO_BACKEND_VENTAS):$(tag)
	$(DOCKER) push $(ECR_REGISTRY)/$(ECR_REPO_BACKEND_VENTAS):$(tag)
	
	# Backend Despachos (Java Spring Boot)
	$(DOCKER) build -t $(ECR_REPO_BACKEND_DESPACHOS) app-k8s/back-bespachos-springboot/api-rest-despacho
	$(DOCKER) tag $(ECR_REPO_BACKEND_DESPACHOS):latest $(ECR_REGISTRY)/$(ECR_REPO_BACKEND_DESPACHOS):$(tag)
	$(DOCKER) push $(ECR_REGISTRY)/$(ECR_REPO_BACKEND_DESPACHOS):$(tag)
	
	# Database
	$(DOCKER) build -t $(ECR_REPO_DB) app-k8s/db
	$(DOCKER) tag $(ECR_REPO_DB):latest $(ECR_REGISTRY)/$(ECR_REPO_DB):$(tag)
	$(DOCKER) push $(ECR_REGISTRY)/$(ECR_REPO_DB):$(tag)
	
	@echo "[publish] ¡Todas las imágenes se subieron exitosamente a Amazon ECR!"

# ==============================================================================
# SECCIÓN 2: OPERACIÓN Y CONTROL EN KUBERNETES (EKS)
# ==============================================================================

deploy:
	@echo "[deploy] Aplicando Namespace base..."
	$(KUBECTL) apply -f app-k8s/k8s/namespace.yaml
	@echo "[deploy] Montando infraestructura de base de datos..."
	$(KUBECTL) apply -f app-k8s/k8s/mysql-secret.yaml
	$(KUBECTL) apply -f app-k8s/k8s/mysql-service.yaml
	$(KUBECTL) apply -f app-k8s/k8s/mysql-deployment.yaml
	@echo "[deploy] Esperando estabilidad en Pod MySQL..."
	$(KUBECTL) wait --namespace=$(NAMESPACE) --for=condition=ready pod -l app=mysql-db --timeout=90s
	@echo "[deploy] Levantando microservicios de la aplicación..."
	$(KUBECTL) apply -f app-k8s/k8s/backend-ventas-service.yaml
	$(KUBECTL) apply -f app-k8s/k8s/backend-ventas-deployment.yaml
	$(KUBECTL) apply -f app-k8s/k8s/backend-despachos-service.yaml
	$(KUBECTL) apply -f app-k8s/k8s/backend-despachos-deployment.yaml
	$(KUBECTL) apply -f app-k8s/k8s/frontend-service.yaml
	$(KUBECTL) apply -f app-k8s/k8s/frontend-deployment.yaml
	@echo "[deploy] Configurando políticas de Autoescalado (HPA)..."
	$(KUBECTL) apply -f app-k8s/k8s/hpa.yaml
	@echo "¡Todo el ecosistema Innovatech ha sido desplegado exitosamente!"

status:
	@echo "--- RECURSOS DE KUBERNETES EN EL NAMESPACE: $(NAMESPACE) ---"
	$(KUBECTL) get pods,svc,hpa -n $(NAMESPACE)

undeploy:
	@echo "[undeploy] Destruyendo recursos de Kubernetes..."
	$(KUBECTL) delete -f app-k8s/k8s/hpa.yaml || true
	$(KUBECTL) delete -f app-k8s/k8s/frontend-deployment.yaml,app-k8s/k8s/frontend-service.yaml || true
	$(KUBECTL) delete -f app-k8s/k8s/backend-despachos-deployment.yaml,app-k8s/k8s/backend-despachos-service.yaml || true
	$(KUBECTL) delete -f app-k8s/k8s/backend-ventas-deployment.yaml,app-k8s/k8s/backend-ventas-service.yaml || true
	$(KUBECTL) delete -f app-k8s/k8s/mysql-deployment.yaml,app-k8s/k8s/mysql-service.yaml,app-k8s/k8s/mysql-secret.yaml || true
	@echo "[undeploy] Clúster limpio."
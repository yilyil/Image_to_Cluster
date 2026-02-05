.PHONY: help check-deps install-deps create-cluster delete-cluster build-image import-image deploy undeploy forward-port status clean all

# Variables
IMAGE_NAME := custom-nginx
IMAGE_TAG := latest
CLUSTER_NAME := lab
CLUSTER_SERVERS := 1
CLUSTER_AGENTS := 2
PORT := 8080
SERVICE_PORT := 80

# Couleurs pour l'affichage
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ Aide

help: ## Affiche ce message d'aide
	@echo "=========================================="
	@echo "📚 Makefile - Atelier Image to Cluster"
	@echo "=========================================="
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Installation et Vérification

check-deps: ## Vérifie que toutes les dépendances sont installées
	@echo "$(GREEN)🔍 Vérification des dépendances...$(NC)"
	@bash scripts/check-deps.sh

install-deps: ## Installe les dépendances manquantes (Packer, K3d, Ansible)
	@echo "$(GREEN)📦 Installation des dépendances...$(NC)"
	@echo ""
	@echo "Installation de Packer..."
	@if ! command -v packer &> /dev/null; then \
		wget -q https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip && \
		unzip -q packer_*.zip && \
		sudo mv packer /usr/local/bin/ && \
		rm packer_*.zip && \
		echo "✅ Packer installé"; \
	else \
		echo "✅ Packer déjà installé"; \
	fi
	@echo ""
	@echo "Installation de K3d..."
	@if ! command -v k3d &> /dev/null; then \
		curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash && \
		echo "✅ K3d installé"; \
	else \
		echo "✅ K3d déjà installé"; \
	fi
	@echo ""
	@echo "Installation d'Ansible..."
	@if ! command -v ansible &> /dev/null; then \
		pip install --quiet ansible && \
		echo "✅ Ansible installé"; \
	else \
		echo "✅ Ansible déjà installé"; \
	fi
	@echo ""
	@echo "$(GREEN)✅ Toutes les dépendances sont installées !$(NC)"

##@ Cluster Kubernetes

create-cluster: ## Crée le cluster K3d (1 master + 2 workers)
	@echo "$(GREEN)☸️  Création du cluster K3d...$(NC)"
	@if k3d cluster list | grep -q "$(CLUSTER_NAME)"; then \
		echo "$(YELLOW)⚠️  Le cluster $(CLUSTER_NAME) existe déjà$(NC)"; \
	else \
		k3d cluster create $(CLUSTER_NAME) \
			--servers $(CLUSTER_SERVERS) \
			--agents $(CLUSTER_AGENTS) \
			--port "$(PORT):30080@server:0" && \
		echo "" && \
		echo "$(GREEN)✅ Cluster créé avec succès !$(NC)" && \
		echo "" && \
		kubectl get nodes; \
	fi

delete-cluster: ## Supprime le cluster K3d
	@echo "$(RED)🗑️  Suppression du cluster K3d...$(NC)"
	@k3d cluster delete $(CLUSTER_NAME) || true
	@echo "$(GREEN)✅ Cluster supprimé$(NC)"

##@ Build et Import de l'Image

build-image: ## Construit l'image Docker personnalisée avec Packer
	@echo "$(GREEN)🐳 Build de l'image avec Packer...$(NC)"
	@cd packer && \
	packer init nginx.pkr.hcl && \
	packer build \
		-var "image_name=$(IMAGE_NAME)" \
		-var "image_tag=$(IMAGE_TAG)" \
		nginx.pkr.hcl
	@echo ""
	@echo "$(GREEN)✅ Image construite avec succès !$(NC)"
	@echo ""
	@docker images $(IMAGE_NAME)

import-image: ## Importe l'image dans le cluster K3d
	@echo "$(GREEN)📦 Import de l'image dans K3d...$(NC)"
	@bash scripts/import-image.sh $(IMAGE_NAME) $(IMAGE_TAG) $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Image importée$(NC)"

##@ Déploiement

deploy: ## Déploie l'application sur K3d avec Ansible
	@echo "$(GREEN)🚀 Déploiement de l'application avec Ansible...$(NC)"
	@cd ansible && \
	ansible-playbook -i inventory.ini deploy.yml
	@echo ""
	@echo "$(GREEN)=========================================="
	@echo "✅ Déploiement terminé !"
	@echo "==========================================$(NC)"

undeploy: ## Supprime le déploiement de l'application
	@echo "$(RED)🗑️  Suppression du déploiement...$(NC)"
	@kubectl delete deployment custom-nginx --ignore-not-found=true
	@kubectl delete service custom-nginx --ignore-not-found=true
	@echo "$(GREEN)✅ Application supprimée$(NC)"

##@ Accès à l'Application

forward-port: ## Forward le port pour accéder à l'application (Ctrl+C pour arrêter)
	@echo "$(GREEN)🌐 Forwarding du port $(PORT) vers le service...$(NC)"
	@echo "$(YELLOW)💡 Dans GitHub Codespaces: Allez dans PORTS et rendez public le port $(PORT)$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop$(NC)"
	@kubectl port-forward svc/custom-nginx $(PORT):$(SERVICE_PORT)

status: ## Affiche l'état du cluster et de l'application
	@echo "$(GREEN)=========================================="
	@echo "📊 État du Cluster et de l'Application"
	@echo "==========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Nœuds du cluster:$(NC)"
	@kubectl get nodes
	@echo ""
	@echo "$(YELLOW)Pods:$(NC)"
	@kubectl get pods -l app=custom-nginx
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	@kubectl get svc custom-nginx
	@echo ""
	@echo "$(YELLOW)Deployments:$(NC)"
	@kubectl get deployment custom-nginx
	@echo ""

##@ Nettoyage

clean: ## Nettoie tout (cluster + images Docker)
	@echo "$(RED)🧹 Nettoyage complet...$(NC)"
	@make undeploy || true
	@make delete-cluster || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

##@ Pipeline Complet

all: install-deps create-cluster build-image import-image deploy status ## Pipeline complet: installation → création cluster → build → import → deploy
	@echo ""
	@echo "$(GREEN)=========================================="
	@echo "🎉 Pipeline complet terminé avec succès !"
	@echo "==========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Pour accéder à l'application:$(NC)"
	@echo "1. Exécutez: make forward-port"
	@echo "2. Dans GitHub Codespaces, allez dans l'onglet PORTS"
	@echo "3. Rendez public le port $(PORT)"
	@echo "4. Cliquez sur l'URL pour accéder à l'application"
	@echo ""

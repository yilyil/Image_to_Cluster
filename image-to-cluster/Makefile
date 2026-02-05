.PHONY: help install-deps create-cluster delete-cluster build-image import-image deploy status all

GREEN  := \033[0;32m
YELLOW := \033[1;33m
RED    := \033[0;31m
NC     := \033[0m

all: install-deps create-cluster build-image import-image deploy status

install-deps:
	@echo "$(GREEN)📦 Installation automatique des dépendances...$(NC)"
	@if ! command -v packer-bin &> /dev/null; then \
		echo "Installation de Packer..."; \
		wget -q https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip -O /tmp/packer.zip && \
		unzip -o -q /tmp/packer.zip -d /tmp/ && \
		sudo mv /tmp/packer /usr/local/bin/packer-bin && \
		sudo chmod +x /usr/local/bin/packer-bin && \
		rm -f /tmp/packer.zip && echo "✅ Packer installé"; \
	else \
		echo "✅ Packer-bin déjà présent"; \
	fi
	@if ! command -v k3d &> /dev/null; then \
		echo "Installation de K3d..."; \
		curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; \
	else \
		echo "✅ K3d déjà présent"; \
	fi
	@if ! command -v ansible &> /dev/null; then \
		echo "Installation d'Ansible..."; \
		pip install --quiet ansible && \
		ansible-galaxy collection install kubernetes.core && \
		echo "✅ Ansible installé"; \
	else \
		echo "✅ Ansible déjà présent"; \
	fi

create-cluster:
	@echo "$(GREEN)☸️ Création du cluster K3d...$(NC)"
	@if k3d cluster get lab >/dev/null 2>&1; then \
		echo "$(YELLOW)⚠️ Le cluster lab existe déjà$(NC)"; \
	else \
		k3d cluster create lab --servers 1 --agents 2 --port "8080:30080@server:0"; \
	fi

build-image:
	@echo "$(GREEN)🐳 Build Packer...$(NC)"
	@cd packer && packer-bin init nginx.pkr.hcl && packer-bin build nginx.pkr.hcl

import-image:
	@echo "$(GREEN)📦 Import K3d...$(NC)"
	@k3d image import custom-nginx:latest -c lab

deploy:
	@echo "$(GREEN)🚀 Déploiement Ansible...$(NC)"
	@mkdir -p ansible
	@printf "[local]\nlocalhost ansible_connection=local\n" > ansible/inventory.ini
	@cd ansible && ansible-playbook -i inventory.ini deploy.yml

status:
	@echo "$(GREEN)📊 État du déploiement :$(NC)"
	@kubectl get nodes
	@kubectl get pods

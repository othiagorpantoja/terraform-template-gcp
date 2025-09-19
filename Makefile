# Makefile para Terraform GCP Infrastructure
# Este Makefile facilita o gerenciamento da infraestrutura

.PHONY: help setup validate plan apply destroy clean dev prod

# Variáveis
TERRAFORM_VERSION := 1.5.0
ENVIRONMENT ?= dev

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Função para imprimir mensagens coloridas
define print_message
	@echo -e "$(GREEN)[INFO]$(NC) $1"
endef

define print_warning
	@echo -e "$(YELLOW)[WARNING]$(NC) $1"
endef

define print_error
	@echo -e "$(RED)[ERROR]$(NC) $1"
endef

define print_header
	@echo -e "$(BLUE)================================$(NC)"
	@echo -e "$(BLUE)$1$(NC)"
	@echo -e "$(BLUE)================================$(NC)"
endef

# Ajuda
help: ## Mostra esta ajuda
	@echo "Terraform GCP Infrastructure - Makefile"
	@echo ""
	@echo "Uso: make [COMANDO] [ENVIRONMENT=dev|staging|prod]"
	@echo ""
	@echo "Comandos disponíveis:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Exemplos:"
	@echo "  make setup"
	@echo "  make validate ENVIRONMENT=dev"
	@echo "  make plan ENVIRONMENT=staging"
	@echo "  make apply ENVIRONMENT=prod"

# Configuração inicial
setup: ## Executa configuração inicial
	$(call print_header,"Configuração Inicial")
	@if [ -f "scripts/setup.sh" ]; then \
		chmod +x scripts/setup.sh && ./scripts/setup.sh; \
	else \
		$(call print_error,"Script setup.sh não encontrado"); \
		exit 1; \
	fi

# Validação
validate: ## Valida a sintaxe e estrutura do Terraform
	$(call print_header,"Validação do Terraform")
	@if [ -f "scripts/validate.sh" ]; then \
		chmod +x scripts/validate.sh && ./scripts/validate.sh; \
	else \
		$(call print_error,"Script validate.sh não encontrado"); \
		exit 1; \
	fi

# Inicialização
init: ## Inicializa o Terraform para o ambiente especificado
	$(call print_header,"Inicializando Terraform - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform init
	$(call print_message,"Terraform inicializado para $(ENVIRONMENT)")

# Planejamento
plan: ## Executa terraform plan para o ambiente especificado
	$(call print_header,"Planejando mudanças - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform plan
	$(call print_message,"Plano executado para $(ENVIRONMENT)")

# Aplicação
apply: ## Executa terraform apply para o ambiente especificado
	$(call print_header,"Aplicando mudanças - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform apply
	@cd envs/$(ENVIRONMENT) && terraform output
	$(call print_message,"Aplicação executada para $(ENVIRONMENT)")

# Aplicação automática
apply-auto: ## Executa terraform apply com auto-approve
	$(call print_header,"Aplicando mudanças automaticamente - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform apply -auto-approve
	@cd envs/$(ENVIRONMENT) && terraform output
	$(call print_message,"Aplicação automática executada para $(ENVIRONMENT)")

# Destruição
destroy: ## Executa terraform destroy para o ambiente especificado
	$(call print_header,"Destruindo recursos - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@echo -e "$(YELLOW)ATENÇÃO: Esta operação irá destruir todos os recursos do ambiente $(ENVIRONMENT)$(NC)"
	@read -p "Tem certeza? (y/N): " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd envs/$(ENVIRONMENT) && terraform destroy; \
		$(call print_message,"Recursos destruídos para $(ENVIRONMENT)"); \
	else \
		$(call print_message,"Operação cancelada"); \
	fi

# Destruição automática
destroy-auto: ## Executa terraform destroy com auto-approve
	$(call print_header,"Destruindo recursos automaticamente - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform destroy -auto-approve
	$(call print_message,"Recursos destruídos automaticamente para $(ENVIRONMENT)")

# Outputs
output: ## Mostra os outputs do ambiente especificado
	$(call print_header,"Outputs - $(ENVIRONMENT)")
	@if [ ! -d "envs/$(ENVIRONMENT)" ]; then \
		$(call print_error,"Ambiente $(ENVIRONMENT) não encontrado"); \
		exit 1; \
	fi
	@cd envs/$(ENVIRONMENT) && terraform output

# Formatação
fmt: ## Formata os arquivos Terraform
	$(call print_header,"Formatando arquivos Terraform")
	@find . -name "*.tf" -exec terraform fmt {} \;
	$(call print_message,"Arquivos formatados")

# Limpeza
clean: ## Remove arquivos temporários e cache
	$(call print_header,"Limpando arquivos temporários")
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -name "terraform.tfstate*" -delete 2>/dev/null || true
	@find . -name "*.tfplan" -delete 2>/dev/null || true
	$(call print_message,"Limpeza concluída")

# Comandos específicos para dev
dev: ## Comandos para ambiente de desenvolvimento
	$(call print_header,"Ambiente de Desenvolvimento")
	@echo "Comandos disponíveis para dev:"
	@echo "  make init ENVIRONMENT=dev"
	@echo "  make plan ENVIRONMENT=dev"
	@echo "  make apply ENVIRONMENT=dev"
	@echo "  make destroy ENVIRONMENT=dev"

# Comandos específicos para staging
staging: ## Comandos para ambiente de homologação
	$(call print_header,"Ambiente de Homologação")
	@echo "Comandos disponíveis para staging:"
	@echo "  make init ENVIRONMENT=staging"
	@echo "  make plan ENVIRONMENT=staging"
	@echo "  make apply ENVIRONMENT=staging"
	@echo "  make destroy ENVIRONMENT=staging"

# Comandos específicos para prod
prod: ## Comandos para ambiente de produção
	$(call print_header,"Ambiente de Produção")
	@echo "Comandos disponíveis para prod:"
	@echo "  make init ENVIRONMENT=prod"
	@echo "  make plan ENVIRONMENT=prod"
	@echo "  make apply ENVIRONMENT=prod"
	@echo "  make destroy ENVIRONMENT=prod"

# Verificação de dependências
check-deps: ## Verifica se as dependências estão instaladas
	$(call print_header,"Verificando dependências")
	@command -v terraform >/dev/null 2>&1 || { $(call print_error,"Terraform não está instalado"); exit 1; }
	@command -v gcloud >/dev/null 2>&1 || { $(call print_error,"Google Cloud SDK não está instalado"); exit 1; }
	@command -v jq >/dev/null 2>&1 || { $(call print_warning,"jq não está instalado (opcional)"); }
	$(call print_message,"Dependências verificadas")

# Instalação de dependências
install-deps: ## Instala as dependências necessárias
	$(call print_header,"Instalando dependências")
	@echo "Instalando TFLint..."
	@curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
	@echo "Instalando TFSec..."
	@curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
	$(call print_message,"Dependências instaladas")

# Comando padrão
.DEFAULT_GOAL := help

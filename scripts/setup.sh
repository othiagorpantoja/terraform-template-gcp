#!/bin/bash

# Script de configuração inicial para Terraform GCP Infrastructure
# Este script configura o ambiente e cria os buckets necessários para o backend

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar se o gcloud está instalado
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK não está instalado. Instale em: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    print_message "Google Cloud SDK encontrado"
}

# Verificar se o terraform está instalado
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform não está instalado. Instale em: https://www.terraform.io/downloads"
        exit 1
    fi
    print_message "Terraform encontrado"
}

# Autenticar com o Google Cloud
authenticate_gcloud() {
    print_header "Autenticação com Google Cloud"
    
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        print_message "Já autenticado com Google Cloud"
    else
        print_message "Fazendo login no Google Cloud..."
        gcloud auth login
    fi
    
    print_message "Configurando Application Default Credentials..."
    gcloud auth application-default login
}

# Criar buckets para backend do Terraform
create_backend_buckets() {
    print_header "Criando buckets para backend do Terraform"
    
    read -p "Digite o ID do projeto GCP: " PROJECT_ID
    read -p "Digite a região para os buckets (ex: us-central1): " REGION
    
    # Bucket para dev
    DEV_BUCKET="terraform-state-dev-${PROJECT_ID}"
    print_message "Criando bucket para dev: $DEV_BUCKET"
    
    if gsutil ls -b gs://$DEV_BUCKET &> /dev/null; then
        print_warning "Bucket $DEV_BUCKET já existe"
    else
        gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$DEV_BUCKET
        gsutil versioning set on gs://$DEV_BUCKET
        print_message "Bucket $DEV_BUCKET criado com sucesso"
    fi
    
    # Bucket para staging
    STAGING_BUCKET="terraform-state-staging-${PROJECT_ID}"
    print_message "Criando bucket para staging: $STAGING_BUCKET"
    
    if gsutil ls -b gs://$STAGING_BUCKET &> /dev/null; then
        print_warning "Bucket $STAGING_BUCKET já existe"
    else
        gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$STAGING_BUCKET
        gsutil versioning set on gs://$STAGING_BUCKET
        print_message "Bucket $STAGING_BUCKET criado com sucesso"
    fi
    
    # Bucket para prod
    PROD_BUCKET="terraform-state-prod-${PROJECT_ID}"
    print_message "Criando bucket para prod: $PROD_BUCKET"
    
    if gsutil ls -b gs://$PROD_BUCKET &> /dev/null; then
        print_warning "Bucket $PROD_BUCKET já existe"
    else
        gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$PROD_BUCKET
        gsutil versioning set on gs://$PROD_BUCKET
        print_message "Bucket $PROD_BUCKET criado com sucesso"
    fi
}

# Configurar variáveis de ambiente
setup_environment() {
    print_header "Configurando variáveis de ambiente"
    
    echo "export GOOGLE_PROJECT=$PROJECT_ID" >> ~/.bashrc
    echo "export GOOGLE_REGION=$REGION" >> ~/.bashrc
    
    print_message "Variáveis de ambiente configuradas"
    print_warning "Execute 'source ~/.bashrc' para aplicar as variáveis"
}

# Criar arquivos de configuração
create_config_files() {
    print_header "Criando arquivos de configuração"
    
    # Copiar arquivos de exemplo
    if [ -f "envs/dev/terraform.tfvars.example" ]; then
        cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars
        print_message "Arquivo envs/dev/terraform.tfvars criado"
    fi
    
    if [ -f "envs/staging/terraform.tfvars.example" ]; then
        cp envs/staging/terraform.tfvars.example envs/staging/terraform.tfvars
        print_message "Arquivo envs/staging/terraform.tfvars criado"
    fi
    
    if [ -f "envs/prod/terraform.tfvars.example" ]; then
        cp envs/prod/terraform.tfvars.example envs/prod/terraform.tfvars
        print_message "Arquivo envs/prod/terraform.tfvars criado"
    fi
    
    print_warning "Edite os arquivos terraform.tfvars com suas configurações específicas"
}

# Verificar permissões necessárias
check_permissions() {
    print_header "Verificando permissões necessárias"
    
    print_message "Verificando permissões do projeto $PROJECT_ID..."
    
    # Verificar permissões básicas
    if gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="value(bindings.members)" | grep -q "$(gcloud config get-value account)"; then
        print_message "Usuário tem acesso ao projeto"
    else
        print_warning "Usuário pode não ter permissões adequadas no projeto"
    fi
    
    # Listar permissões necessárias
    print_message "Permissões necessárias para este projeto:"
    echo "- roles/compute.admin"
    echo "- roles/container.admin"
    echo "- roles/cloudsql.admin"
    echo "- roles/storage.admin"
    echo "- roles/iam.serviceAccountAdmin"
    echo "- roles/secretmanager.admin"
    echo "- roles/servicenetworking.networksAdmin"
    echo "- roles/resourcemanager.projectIamAdmin"
}

# Função principal
main() {
    print_header "Configuração Inicial - Terraform GCP Infrastructure"
    
    check_gcloud
    check_terraform
    authenticate_gcloud
    create_backend_buckets
    setup_environment
    create_config_files
    check_permissions
    
    print_header "Configuração Concluída!"
    print_message "Próximos passos:"
    echo "1. Edite os arquivos terraform.tfvars em envs/dev/, envs/staging/ e envs/prod/"
    echo "2. Configure suas chaves SSH"
    echo "3. Execute 'source ~/.bashrc' para aplicar as variáveis de ambiente"
    echo "4. Navegue para o ambiente desejado e execute:"
    echo "   terraform init"
    echo "   terraform plan"
    echo "   terraform apply"
    echo ""
    echo "Ambientes disponíveis:"
    echo "  - envs/dev/     (desenvolvimento)"
    echo "  - envs/staging/ (homologação)"
    echo "  - envs/prod/    (produção)"
}

# Executar função principal
main "$@"

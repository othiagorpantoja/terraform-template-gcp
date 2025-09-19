#!/bin/bash

# Script de validação para Terraform GCP Infrastructure
# Este script valida a sintaxe e estrutura dos arquivos Terraform

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

# Verificar se o terraform está instalado
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform não está instalado. Instale em: https://www.terraform.io/downloads"
        exit 1
    fi
    print_message "Terraform encontrado: $(terraform version -json | jq -r '.terraform_version')"
}

# Verificar se o tflint está instalado
check_tflint() {
    if ! command -v tflint &> /dev/null; then
        print_warning "TFLint não está instalado. Instalando..."
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    fi
    print_message "TFLint encontrado: $(tflint --version)"
}

# Verificar se o tfsec está instalado
check_tfsec() {
    if ! command -v tfsec &> /dev/null; then
        print_warning "TFSec não está instalado. Instalando..."
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    fi
    print_message "TFSec encontrado: $(tfsec --version)"
}

# Validar sintaxe do Terraform
validate_terraform_syntax() {
    print_header "Validando sintaxe do Terraform"
    
    local environments=("dev" "staging" "prod")
    local errors=0
    
    for env in "${environments[@]}"; do
        print_message "Validando ambiente: $env"
        
        if [ -d "envs/$env" ]; then
            cd "envs/$env"
            
            # Inicializar Terraform se necessário
            if [ ! -d ".terraform" ]; then
                print_message "Inicializando Terraform para $env..."
                terraform init -backend=false
            fi
            
            # Validar sintaxe
            if terraform validate; then
                print_message "Sintaxe válida para $env"
            else
                print_error "Erro de sintaxe em $env"
                errors=$((errors + 1))
            fi
            
            # Formatar arquivos
            print_message "Formatando arquivos em $env..."
            terraform fmt -recursive
            
            cd - > /dev/null
        else
            print_warning "Diretório envs/$env não encontrado"
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_message "Todas as validações de sintaxe passaram"
    else
        print_error "$errors ambiente(s) com erros de sintaxe"
        exit 1
    fi
}

# Validar com TFLint
validate_with_tflint() {
    print_header "Validando com TFLint"
    
    local environments=("dev" "staging" "prod")
    local errors=0
    
    for env in "${environments[@]}"; do
        print_message "Executando TFLint em: $env"
        
        if [ -d "envs/$env" ]; then
            cd "envs/$env"
            
            if tflint --init && tflint; then
                print_message "TFLint passou para $env"
            else
                print_error "TFLint encontrou problemas em $env"
                errors=$((errors + 1))
            fi
            
            cd - > /dev/null
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_message "Todas as validações TFLint passaram"
    else
        print_error "$errors ambiente(s) com problemas no TFLint"
        exit 1
    fi
}

# Validar segurança com TFSec
validate_with_tfsec() {
    print_header "Validando segurança com TFSec"
    
    local environments=("dev" "staging" "prod")
    local errors=0
    
    for env in "${environments[@]}"; do
        print_message "Executando TFSec em: $env"
        
        if [ -d "envs/$env" ]; then
            cd "envs/$env"
            
            if tfsec . --no-color; then
                print_message "TFSec passou para $env"
            else
                print_warning "TFSec encontrou problemas de segurança em $env"
                errors=$((errors + 1))
            fi
            
            cd - > /dev/null
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_message "Todas as validações TFSec passaram"
    else
        print_warning "$errors ambiente(s) com problemas de segurança no TFSec"
    fi
}

# Validar estrutura de módulos
validate_modules() {
    print_header "Validando estrutura de módulos"
    
    local modules=("network" "gke" "sql" "storage" "loadbalancer" "iam" "vm" "project")
    local errors=0
    
    for module in "${modules[@]}"; do
        print_message "Validando módulo: $module"
        
        if [ -d "modules/$module" ]; then
            cd "modules/$module"
            
            # Verificar arquivos obrigatórios
            if [ ! -f "main.tf" ]; then
                print_error "Arquivo main.tf não encontrado em modules/$module"
                errors=$((errors + 1))
            fi
            
            if [ ! -f "variables.tf" ]; then
                print_error "Arquivo variables.tf não encontrado em modules/$module"
                errors=$((errors + 1))
            fi
            
            if [ ! -f "outputs.tf" ]; then
                print_error "Arquivo outputs.tf não encontrado em modules/$module"
                errors=$((errors + 1))
            fi
            
            # Validar sintaxe do módulo
            if terraform validate; then
                print_message "Módulo $module válido"
            else
                print_error "Erro de sintaxe no módulo $module"
                errors=$((errors + 1))
            fi
            
            cd - > /dev/null
        else
            print_error "Módulo $module não encontrado"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_message "Todos os módulos são válidos"
    else
        print_error "$errors módulo(s) com problemas"
        exit 1
    fi
}

# Validar arquivos de configuração
validate_config_files() {
    print_header "Validando arquivos de configuração"
    
    local environments=("dev" "staging" "prod")
    local errors=0
    
    for env in "${environments[@]}"; do
        print_message "Validando configurações de: $env"
        
        # Verificar se terraform.tfvars existe
        if [ ! -f "envs/$env/terraform.tfvars" ]; then
            print_warning "Arquivo terraform.tfvars não encontrado em envs/$env"
            print_message "Copie terraform.tfvars.example para terraform.tfvars e configure"
        fi
        
        # Verificar se provider.tf existe
        if [ ! -f "envs/$env/provider.tf" ]; then
            print_error "Arquivo provider.tf não encontrado em envs/$env"
            errors=$((errors + 1))
        fi
        
        # Verificar se main.tf existe
        if [ ! -f "envs/$env/main.tf" ]; then
            print_error "Arquivo main.tf não encontrado em envs/$env"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_message "Arquivos de configuração válidos"
    else
        print_error "$errors problema(s) nos arquivos de configuração"
        exit 1
    fi
}

# Função principal
main() {
    print_header "Validação - Terraform GCP Infrastructure"
    
    check_terraform
    check_tflint
    check_tfsec
    validate_config_files
    validate_modules
    validate_terraform_syntax
    validate_with_tflint
    validate_with_tfsec
    
    print_header "Validação Concluída!"
    print_message "Todos os testes passaram com sucesso!"
}

# Executar função principal
main "$@"

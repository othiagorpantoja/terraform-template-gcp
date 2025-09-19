#!/bin/bash

# Script de deploy para Terraform GCP Infrastructure
# Este script automatiza o processo de deploy para diferentes ambientes

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

# Função de ajuda
show_help() {
    echo "Uso: $0 [OPÇÕES] AMBIENTE"
    echo ""
    echo "AMBIENTE:"
    echo "  dev      Deploy para ambiente de desenvolvimento"
    echo "  staging  Deploy para ambiente de homologação"
    echo "  prod     Deploy para ambiente de produção"
    echo ""
    echo "OPÇÕES:"
    echo "  -h, --help          Mostra esta ajuda"
    echo "  -p, --plan          Apenas executa terraform plan"
    echo "  -a, --apply         Executa terraform apply"
    echo "  -d, --destroy       Executa terraform destroy"
    echo "  -i, --init          Apenas executa terraform init"
    echo "  -v, --validate      Apenas executa terraform validate"
    echo "  -f, --force         Força a execução sem confirmação"
    echo "  -t, --target        Especifica um target específico"
    echo ""
    echo "Exemplos:"
    echo "  $0 dev --plan"
    echo "  $0 staging --apply"
    echo "  $0 prod --apply"
    echo "  $0 dev --destroy --force"
    echo "  $0 staging --target=module.gke"
}

# Verificar se o terraform está instalado
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform não está instalado. Instale em: https://www.terraform.io/downloads"
        exit 1
    fi
    print_message "Terraform encontrado: $(terraform version -json | jq -r '.terraform_version')"
}

# Verificar se o gcloud está instalado
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK não está instalado. Instale em: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    print_message "Google Cloud SDK encontrado"
}

# Verificar autenticação
check_auth() {
    print_message "Verificando autenticação..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        print_error "Não autenticado com Google Cloud. Execute: gcloud auth login"
        exit 1
    fi
    
    if ! gcloud auth application-default print-access-token &> /dev/null; then
        print_error "Application Default Credentials não configuradas. Execute: gcloud auth application-default login"
        exit 1
    fi
    
    print_message "Autenticação verificada"
}

# Confirmar ação
confirm_action() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    local action=$1
    local environment=$2
    
    echo -e "${YELLOW}Você está prestes a executar '$action' no ambiente '$environment'${NC}"
    read -p "Tem certeza? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Operação cancelada"
        exit 0
    fi
}

# Executar terraform init
terraform_init() {
    local environment=$1
    
    print_header "Inicializando Terraform para $environment"
    
    cd "envs/$environment"
    
    if terraform init; then
        print_message "Terraform inicializado com sucesso"
    else
        print_error "Falha ao inicializar Terraform"
        exit 1
    fi
    
    cd - > /dev/null
}

# Executar terraform validate
terraform_validate() {
    local environment=$1
    
    print_header "Validando Terraform para $environment"
    
    cd "envs/$environment"
    
    if terraform validate; then
        print_message "Terraform validado com sucesso"
    else
        print_error "Falha na validação do Terraform"
        exit 1
    fi
    
    cd - > /dev/null
}

# Executar terraform plan
terraform_plan() {
    local environment=$1
    local target=$2
    
    print_header "Planejando mudanças para $environment"
    
    cd "envs/$environment"
    
    local plan_cmd="terraform plan"
    
    if [ -n "$target" ]; then
        plan_cmd="$plan_cmd -target=$target"
    fi
    
    if $plan_cmd; then
        print_message "Plano executado com sucesso"
    else
        print_error "Falha ao executar o plano"
        exit 1
    fi
    
    cd - > /dev/null
}

# Executar terraform apply
terraform_apply() {
    local environment=$1
    local target=$2
    
    print_header "Aplicando mudanças para $environment"
    
    cd "envs/$environment"
    
    local apply_cmd="terraform apply"
    
    if [ -n "$target" ]; then
        apply_cmd="$apply_cmd -target=$target"
    fi
    
    if [ "$FORCE" = true ]; then
        apply_cmd="$apply_cmd -auto-approve"
    fi
    
    if $apply_cmd; then
        print_message "Aplicação executada com sucesso"
    else
        print_error "Falha ao aplicar as mudanças"
        exit 1
    fi
    
    cd - > /dev/null
}

# Executar terraform destroy
terraform_destroy() {
    local environment=$1
    local target=$2
    
    print_header "Destruindo recursos para $environment"
    
    cd "envs/$environment"
    
    local destroy_cmd="terraform destroy"
    
    if [ -n "$target" ]; then
        destroy_cmd="$destroy_cmd -target=$target"
    fi
    
    if [ "$FORCE" = true ]; then
        destroy_cmd="$destroy_cmd -auto-approve"
    fi
    
    if $destroy_cmd; then
        print_message "Destruição executada com sucesso"
    else
        print_error "Falha ao destruir os recursos"
        exit 1
    fi
    
    cd - > /dev/null
}

# Mostrar outputs
show_outputs() {
    local environment=$1
    
    print_header "Outputs do ambiente $environment"
    
    cd "envs/$environment"
    
    if terraform output; then
        print_message "Outputs exibidos com sucesso"
    else
        print_warning "Nenhum output disponível ou erro ao exibir outputs"
    fi
    
    cd - > /dev/null
}

# Verificar se o ambiente existe
check_environment() {
    local environment=$1
    
    if [ ! -d "envs/$environment" ]; then
        print_error "Ambiente '$environment' não encontrado"
        print_message "Ambientes disponíveis:"
        ls -1 envs/ 2>/dev/null || print_message "Nenhum ambiente encontrado"
        exit 1
    fi
}

# Função principal
main() {
    local environment=""
    local action=""
    local target=""
    FORCE=false
    
    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -p|--plan)
                action="plan"
                shift
                ;;
            -a|--apply)
                action="apply"
                shift
                ;;
            -d|--destroy)
                action="destroy"
                shift
                ;;
            -i|--init)
                action="init"
                shift
                ;;
            -v|--validate)
                action="validate"
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -t|--target)
                target="$2"
                shift 2
                ;;
            dev|staging|prod)
                environment="$1"
                shift
                ;;
            *)
                print_error "Argumento desconhecido: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Verificar se o ambiente foi especificado
    if [ -z "$environment" ]; then
        print_error "Ambiente não especificado"
        show_help
        exit 1
    fi
    
    # Verificar se a ação foi especificada
    if [ -z "$action" ]; then
        print_error "Ação não especificada"
        show_help
        exit 1
    fi
    
    # Verificações iniciais
    check_terraform
    check_gcloud
    check_auth
    check_environment "$environment"
    
    # Confirmar ação se necessário
    if [ "$action" = "destroy" ] || [ "$action" = "apply" ]; then
        confirm_action "$action" "$environment"
    fi
    
    # Executar ação
    case $action in
        init)
            terraform_init "$environment"
            ;;
        validate)
            terraform_validate "$environment"
            ;;
        plan)
            terraform_plan "$environment" "$target"
            ;;
        apply)
            terraform_apply "$environment" "$target"
            show_outputs "$environment"
            ;;
        destroy)
            terraform_destroy "$environment" "$target"
            ;;
        *)
            print_error "Ação desconhecida: $action"
            exit 1
            ;;
    esac
    
    print_header "Deploy Concluído!"
    print_message "Ação '$action' executada com sucesso no ambiente '$environment'"
}

# Executar função principal
main "$@"

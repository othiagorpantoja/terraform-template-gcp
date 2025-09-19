# Quick Start Guide

Este guia te ajudará a começar rapidamente com a infraestrutura Terraform GCP.

## 🚀 Início Rápido

### 1. Pré-requisitos

- **Terraform** >= 1.5.0
- **Google Cloud SDK** instalado e configurado
- **Projeto GCP** com billing habilitado
- **Chaves SSH** configuradas

### 2. Configuração Inicial

```bash
# Clone o repositório
git clone <repository-url>
cd terraform-gcp-infra

# Execute o script de configuração
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 3. Configurar Variáveis

```bash
# Copie os arquivos de exemplo
cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars
cp envs/prod/terraform.tfvars.example envs/prod/terraform.tfvars

# Edite as variáveis
nano envs/dev/terraform.tfvars
```

### 4. Deploy para Desenvolvimento

```bash
# Navegue para o ambiente dev
cd envs/dev

# Inicialize o Terraform
terraform init

# Planeje as mudanças
terraform plan

# Aplique a infraestrutura
terraform apply
```

### 5. Deploy para Homologação (Staging)

```bash
# Navegue para o ambiente staging
cd envs/staging

# Inicialize o Terraform
terraform init

# Planeje as mudanças
terraform plan

# Aplique a infraestrutura
terraform apply
```

### 6. Deploy para Produção

```bash
# Navegue para o ambiente prod
cd envs/prod

# Inicialize o Terraform
terraform init

# Planeje as mudanças
terraform plan

# Aplique a infraestrutura
terraform apply
```

## 🛠️ Comandos Úteis

### Usando Makefile

```bash
# Ver ajuda
make help

# Configuração inicial
make setup

# Validação
make validate

# Deploy para dev
make init ENVIRONMENT=dev
make plan ENVIRONMENT=dev
make apply ENVIRONMENT=dev

# Deploy para staging
make init ENVIRONMENT=staging
make plan ENVIRONMENT=staging
make apply ENVIRONMENT=staging

# Deploy para prod
make init ENVIRONMENT=prod
make plan ENVIRONMENT=prod
make apply ENVIRONMENT=prod
```

### Usando Scripts

```bash
# Validação completa
./scripts/validate.sh

# Deploy automatizado
./scripts/deploy.sh dev --plan
./scripts/deploy.sh dev --apply
./scripts/deploy.sh staging --apply
./scripts/deploy.sh prod --apply
```

## 📋 Configurações Importantes

### Variáveis Obrigatórias

```hcl
# envs/dev/terraform.tfvars
project_id = "meu-projeto-gcp-dev"
sql_password = "SUA_SENHA_SUPER_SEGURA"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

### Variáveis Opcionais

```hcl
# Configurações de domínio para SSL
domain_name = "meudominio.com"

# Criação de projeto via Terraform
create_project = true
project_name = "Meu Projeto"
billing_account_id = "012345-6789AB-CDEF01"
```

## 🔧 Personalização

### Módulos Disponíveis

- **network**: VPC, subnets, firewall, NAT
- **gke**: Cluster Kubernetes com node pools
- **sql**: Cloud SQL PostgreSQL
- **storage**: Buckets públicos e privados
- **loadbalancer**: Load Balancer HTTP(S)
- **iam**: Service Accounts e permissões
- **vm**: Instâncias de VM
- **project**: Criação de projeto GCP

### Exemplo de Uso de Módulo

```hcl
module "gke" {
  source = "../../modules/gke"
  
  project_id                = var.project_id
  region                    = var.region
  environment               = var.environment
  network_name              = module.network.vpc_name
  subnetwork_name           = module.network.private_subnet_name
  service_account_email     = module.iam.gke_service_account_email
  
  # Configurações específicas
  node_count                = 3
  machine_type              = "e2-medium"
  min_node_count            = 1
  max_node_count            = 10
}
```

## 🔐 Segurança

### Boas Práticas Implementadas

- ✅ Service Accounts com permissões mínimas
- ✅ Rede privada com NAT Gateway
- ✅ Cloud SQL com IP privado
- ✅ Secrets gerenciados via Secret Manager
- ✅ Workload Identity habilitado
- ✅ Firewall rules restritivas
- ✅ Shielded VMs habilitadas

### Configurações de Segurança

```hcl
# SSH restrito a IPs específicos
ssh_source_ranges = ["SEU.IP.PUBLICO/32"]

# Deletion protection em produção
deletion_protection = true

# Secure boot habilitado
enable_secure_boot = true
```

## 📊 Monitoramento

### Logs e Métricas

- **Cloud Logging** habilitado para GKE
- **Cloud Monitoring** configurado
- **Performance Insights** para Cloud SQL
- **Health checks** para Load Balancer

### Alertas

```hcl
# Budget alerts configurados
create_budget = true
budget_amount = "500"
budget_threshold_percent = 0.8
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Erro de permissões**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Bucket de backend não existe**
   ```bash
   gsutil mb gs://terraform-state-dev-PROJECT_ID
   ```

3. **APIs não habilitadas**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   ```

### Logs e Debug

```bash
# Logs do Terraform
export TF_LOG=DEBUG
terraform apply

# Logs do GKE
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
kubectl get pods --all-namespaces
```

## 📚 Próximos Passos

1. **CI/CD**: Configure GitHub Actions ou Cloud Build
2. **Monitoring**: Adicione alertas personalizados
3. **Backup**: Configure backup automático
4. **Scaling**: Implemente auto-scaling
5. **Security**: Adicione WAF e DDoS protection

## 🆘 Suporte

- 📖 [Documentação Completa](README.md)
- 🐛 [Issues](https://github.com/seu-repo/issues)
- 💬 [Discussões](https://github.com/seu-repo/discussions)

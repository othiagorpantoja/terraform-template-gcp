# Ambiente de Staging (Homologação)

Este documento descreve as configurações específicas do ambiente de staging, que serve como um ambiente intermediário entre desenvolvimento e produção.

## 🎯 Objetivo do Staging

O ambiente de staging é projetado para:

- **Testes de integração** completos
- **Validação de mudanças** antes da produção
- **Testes de performance** em ambiente similar à produção
- **Treinamento** de equipes
- **Demonstrações** para stakeholders

## 🔧 Configurações Específicas

### Rede
```hcl
# CIDRs únicos para staging
private_subnet_cidr = "10.5.0.0/16"
public_subnet_cidr  = "10.6.0.0/16"
pods_cidr          = "10.7.0.0/16"
services_cidr      = "10.8.0.0/16"
```

### GKE (Google Kubernetes Engine)
```hcl
# Configurações intermediárias
node_count                = 2
machine_type              = "e2-small"
min_node_count            = 1
max_node_count            = 5
create_system_node_pool   = false
preemptible               = false  # Instâncias estáveis
```

### Cloud SQL
```hcl
# Instância intermediária
tier                      = "db-g1-small"  # 1 vCPU, 1.7GB RAM
availability_type         = "ZONAL"
disk_type                = "PD_SSD"
disk_size                = 50
deletion_protection      = false
point_in_time_recovery   = true
performance_insights     = true
```

### Storage
```hcl
# Lifecycle policies moderadas
private_lifecycle_age     = 60    # 2 meses
public_lifecycle_age      = 15    # 2 semanas
backup_lifecycle_age      = 90    # 3 meses
logs_lifecycle_age        = 15    # 2 semanas
create_backup_bucket      = true
create_logs_bucket        = true
```

### Load Balancer
```hcl
# HTTPS opcional
enable_https             = var.domain_name != ""
ssl_domains              = var.domain_name != "" ? [var.domain_name] : []
backend_timeout          = 30
health_check_path        = "/health"
```

### VM (Bastion Host)
```hcl
# Configurações estáveis
machine_type             = "e2-micro"
disk_size                = 15
preemptible              = false
create_static_ip         = false
enable_secure_boot       = true
enable_vtpm              = true
enable_integrity_monitoring = true
```

## 📊 Comparação de Ambientes

| Configuração | Dev | Staging | Prod |
|--------------|-----|---------|------|
| **GKE Nodes** | 1 | 2 | 3 |
| **Machine Type** | e2-small | e2-small | e2-medium |
| **Max Nodes** | 3 | 5 | 10 |
| **Preemptible** | ✅ | ❌ | ❌ |
| **System Node Pool** | ❌ | ❌ | ✅ |
| **SQL Tier** | db-f1-micro | db-g1-small | db-custom-1-3840 |
| **SQL Disk** | 20GB PD_STANDARD | 50GB PD_SSD | 100GB PD_SSD |
| **SQL Availability** | ZONAL | ZONAL | REGIONAL |
| **Deletion Protection** | ❌ | ❌ | ✅ |
| **HTTPS** | ❌ | 🔶 Opcional | ✅ |
| **Backup Bucket** | ❌ | ✅ | ✅ |
| **Budget** | $100 | $200 | $500 |

## 🔐 Segurança

### Configurações de Segurança
- ✅ **Instâncias estáveis** (não preemptíveis)
- ✅ **Shielded VMs** habilitadas
- ✅ **Secure Boot** ativado
- ✅ **vTPM** habilitado
- ✅ **Integrity Monitoring** ativo
- ✅ **Workload Identity** configurado
- ✅ **Secrets** via Secret Manager

### Acesso
- **SSH**: Configurável via `ssh_source_ranges`
- **HTTPS**: Opcional, configurável via `domain_name`
- **Database**: IP privado apenas
- **Load Balancer**: Health checks configurados

## 💰 Otimização de Custos

### Estratégias Implementadas
- **Recursos intermediários** entre dev e prod
- **Lifecycle policies** moderadas
- **Auto-scaling** configurado
- **Budget alerts** em $200
- **Instâncias estáveis** para testes confiáveis

### Estimativa de Custos (mensal)
- **GKE**: ~$50-80
- **Cloud SQL**: ~$30-50
- **Storage**: ~$10-20
- **Load Balancer**: ~$20-30
- **VM**: ~$5-10
- **Total**: ~$115-190/mês

## 🚀 Deploy para Staging

### 1. Configuração Inicial
```bash
# Copie o arquivo de exemplo
cp envs/staging/terraform.tfvars.example envs/staging/terraform.tfvars

# Edite as variáveis
nano envs/staging/terraform.tfvars
```

### 2. Configurações Recomendadas
```hcl
# terraform.tfvars
project_id = "meu-projeto-gcp-staging"
region     = "us-central1"
zone       = "us-central1-a"
environment = "staging"

# Senha segura para o banco
sql_password = "SUA_SENHA_SUPER_SEGURA"

# Domínio para HTTPS (recomendado)
domain_name = "staging.meudominio.com"

# Chave SSH
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

### 3. Deploy
```bash
# Navegue para o ambiente
cd envs/staging

# Inicialize o Terraform
terraform init

# Planeje as mudanças
terraform plan

# Aplique a infraestrutura
terraform apply
```

### 4. Usando Scripts
```bash
# Deploy automatizado
./scripts/deploy.sh staging --apply

# Usando Makefile
make init ENVIRONMENT=staging
make plan ENVIRONMENT=staging
make apply ENVIRONMENT=staging
```

## 🔄 Workflow Recomendado

### 1. Desenvolvimento → Staging
```bash
# 1. Deploy para dev primeiro
./scripts/deploy.sh dev --apply

# 2. Teste em dev
# 3. Deploy para staging
./scripts/deploy.sh staging --apply

# 4. Testes de integração em staging
# 5. Validação com stakeholders
```

### 2. Staging → Produção
```bash
# 1. Validação completa em staging
# 2. Aprovação para produção
# 3. Deploy para prod
./scripts/deploy.sh prod --apply

# 4. Monitoramento pós-deploy
```

## 📊 Monitoramento

### Métricas Importantes
- **GKE**: CPU, memória, pods
- **Cloud SQL**: Connections, CPU, storage
- **Load Balancer**: Requests, latency, errors
- **Storage**: Usage, lifecycle transitions
- **Budget**: Spending alerts

### Alertas Configurados
- **Budget**: 80% do limite ($160)
- **GKE**: Node failures, pod crashes
- **SQL**: High CPU, connection limits
- **LB**: Health check failures

## 🛠️ Manutenção

### Atualizações
- **GKE**: Auto-upgrade habilitado
- **OS**: Patches automáticos
- **Terraform**: Atualizações manuais

### Backup
- **SQL**: Backup automático diário
- **Storage**: Versionamento habilitado
- **GKE**: Etcd backups automáticos

### Limpeza
```bash
# Limpeza de recursos antigos
make clean

# Destruição do ambiente (cuidado!)
./scripts/deploy.sh staging --destroy
```

## 🆘 Troubleshooting

### Problemas Comuns

1. **Alto uso de CPU no GKE**
   - Verificar aplicações
   - Ajustar resource limits
   - Considerar auto-scaling

2. **Conexões SQL esgotadas**
   - Verificar connection pooling
   - Ajustar max_connections
   - Monitorar aplicações

3. **Custos elevados**
   - Revisar lifecycle policies
   - Verificar recursos não utilizados
   - Ajustar budget alerts

### Logs Úteis
```bash
# Logs do GKE
gcloud container clusters get-credentials staging-gke-cluster --region us-central1
kubectl logs -f deployment/app-deployment

# Logs do SQL
gcloud sql operations list --instance=staging-postgres

# Logs do Load Balancer
gcloud logging read "resource.type=http_load_balancer"
```

## 📚 Próximos Passos

1. **Configurar CI/CD** para deploy automático
2. **Implementar testes automatizados** em staging
3. **Configurar alertas** personalizados
4. **Documentar procedimentos** de rollback
5. **Treinar equipes** no uso do ambiente

---

**🎯 O ambiente de staging está pronto para validar mudanças antes da produção!**

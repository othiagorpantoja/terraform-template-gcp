# Arquitetura da Infraestrutura

Este documento descreve a arquitetura completa da infraestrutura GCP provisionada pelo Terraform.

## 🏗️ Visão Geral

A infraestrutura é projetada seguindo as melhores práticas de segurança, escalabilidade e manutenibilidade, com separação clara entre ambientes de desenvolvimento, homologação e produção.

## 📊 Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        Google Cloud Platform                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Development   │  │    Staging      │  │   Production    │ │
│  │                 │  │                 │  │                 │ │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │    VPC      │ │    │ │    VPC      │ │                    │
│  │ │             │ │    │ │             │ │                    │
│  │ │ ┌─────────┐ │ │    │ │ ┌─────────┐ │ │                    │
│  │ │ │ Public  │ │ │    │ │ │ Public  │ │ │                    │
│  │ │ │ Subnet  │ │ │    │ │ │ Subnet  │ │ │                    │
│  │ │ └─────────┘ │ │    │ │ └─────────┘ │ │                    │
│  │ │             │ │    │ │             │ │                    │
│  │ │ ┌─────────┐ │ │    │ │ ┌─────────┐ │ │                    │
│  │ │ │ Private │ │ │    │ │ │ Private │ │ │                    │
│  │ │ │ Subnet  │ │ │    │ │ │ Subnet  │ │ │                    │
│  │ │ └─────────┘ │ │    │ │ └─────────┘ │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │      GKE        │    │      GKE        │                    │
│  │   (Dev)         │    │   (Prod)        │                    │
│  │                 │    │                 │                    │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │ Node Pool   │ │    │ │ Node Pool   │ │                    │
│  │ │ (e2-small)  │ │    │ │ (e2-medium) │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   Cloud SQL     │    │   Cloud SQL     │                    │
│  │   (Dev)         │    │   (Prod)        │                    │
│  │                 │    │                 │                    │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │ PostgreSQL  │ │    │ │ PostgreSQL  │ │                    │
│  │ │ (db-f1-micro)│ │    │ │ (db-custom) │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   Load Balancer │    │   Load Balancer │                    │
│  │   (Dev)         │    │   (Prod)        │                    │
│  │                 │    │                 │                    │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │ HTTP Only   │ │    │ │ HTTP/HTTPS  │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes da Infraestrutura

### 1. Rede (Network Module)

**Recursos:**
- VPC custom com subnets públicas e privadas
- Cloud NAT para acesso à internet
- Firewall rules configuradas
- IP ranges para pods e serviços do GKE

**Configurações:**
```hcl
# Desenvolvimento
private_subnet_cidr = "10.1.0.0/16"
public_subnet_cidr  = "10.2.0.0/16"
pods_cidr          = "10.3.0.0/16"
services_cidr      = "10.4.0.0/16"

# Produção
private_subnet_cidr = "10.10.0.0/16"
public_subnet_cidr  = "10.20.0.0/16"
pods_cidr          = "10.30.0.0/16"
services_cidr      = "10.40.0.0/16"
```

### 2. GKE (Google Kubernetes Engine)

**Recursos:**
- Cluster Kubernetes com Workload Identity
- Node pools configuráveis
- Rede privada com IP aliases
- Autoscaling habilitado

**Configurações por Ambiente:**

| Configuração | Desenvolvimento | Staging | Produção |
|--------------|-----------------|---------|----------|
| Node Count | 1 | 2 | 3 |
| Machine Type | e2-small | e2-small | e2-medium |
| Min Nodes | 1 | 1 | 1 |
| Max Nodes | 3 | 5 | 10 |
| System Node Pool | Não | Não | Sim |
| Preemptible | Sim | Não | Não |

### 3. Cloud SQL

**Recursos:**
- PostgreSQL com IP privado
- Backup automático configurado
- Point-in-Time Recovery
- Performance Insights
- Secret Manager integration

**Configurações por Ambiente:**

| Configuração | Desenvolvimento | Staging | Produção |
|--------------|-----------------|---------|----------|
| Tier | db-f1-micro | db-g1-small | db-custom-1-3840 |
| Availability | ZONAL | ZONAL | REGIONAL |
| Disk Type | PD_STANDARD | PD_SSD | PD_SSD |
| Disk Size | 20GB | 50GB | 100GB |
| Deletion Protection | Não | Não | Sim |

### 4. Storage (Cloud Storage)

**Recursos:**
- Buckets públicos e privados
- Versionamento habilitado
- Lifecycle policies configuradas
- CORS configurado

**Buckets Criados:**
- `{project}-{env}-private`: Dados da aplicação
- `{project}-{env}-public`: Assets estáticos
- `{project}-{env}-backup`: Backups (apenas prod)
- `{project}-{env}-logs`: Logs do sistema

### 5. Load Balancer

**Recursos:**
- HTTP(S) Load Balancer global
- SSL Certificate gerenciado
- Health checks configurados
- NEG (Network Endpoint Group) para GKE

**Configurações:**
- **Desenvolvimento**: HTTP apenas
- **Staging**: HTTP e HTTPS opcional
- **Produção**: HTTP e HTTPS com SSL

### 6. IAM (Identity and Access Management)

**Service Accounts Criadas:**
- `{env}-gke-sa`: Para nodes do GKE
- `{env}-sql-sa`: Para acesso ao Cloud SQL
- `{env}-app-sa`: Para workloads da aplicação
- `{env}-storage-sa`: Para operações de storage
- `{env}-cicd-sa`: Para pipelines de CI/CD

**Princípios de Segurança:**
- Permissões mínimas necessárias
- Workload Identity para GKE
- Secrets gerenciados via Secret Manager

### 7. VM (Bastion Host)

**Recursos:**
- Instância Debian 11
- IP público configurável
- SSH access via chave pública
- Service Account integrada

**Configurações por Ambiente:**

| Configuração | Desenvolvimento | Staging | Produção |
|--------------|-----------------|---------|----------|
| Machine Type | e2-micro | e2-micro | e2-small |
| Disk Size | 10GB | 15GB | 20GB |
| Preemptible | Sim | Não | Não |
| Static IP | Não | Não | Sim |
| Secure Boot | Não | Sim | Sim |

## 🔐 Segurança

### Rede
- VPC com subnets privadas
- Cloud NAT para acesso à internet
- Firewall rules restritivas
- Private Google Access habilitado

### Acesso
- Service Accounts com permissões mínimas
- Workload Identity para GKE
- SSH restrito a IPs específicos
- Secrets gerenciados via Secret Manager

### Dados
- Cloud SQL com IP privado
- Backup automático configurado
- Encryption em trânsito e em repouso
- Point-in-Time Recovery

## 📈 Escalabilidade

### GKE
- Autoscaling horizontal de pods
- Autoscaling de node pools
- Cluster autoscaling (produção)

### Cloud SQL
- Auto-resize de disco
- Read replicas (produção)
- Connection pooling

### Load Balancer
- Global load balancing
- Health checks automáticos
- SSL termination

## 🔄 Backup e Recuperação

### Cloud SQL
- Backup automático diário
- Point-in-Time Recovery
- Backup retention configurável

### Storage
- Versionamento habilitado
- Lifecycle policies
- Cross-region replication (produção)

### GKE
- Etcd backups automáticos
- Cluster state em GCS
- Node auto-repair

## 📊 Monitoramento

### Logs
- Cloud Logging habilitado
- Structured logging
- Log retention configurável

### Métricas
- Cloud Monitoring
- Custom metrics
- Alerting configurado

### Performance
- Performance Insights (SQL)
- GKE monitoring
- Load Balancer metrics

## 🚀 CI/CD

### Service Account
- `{env}-cicd-sa` com permissões específicas
- Workload Identity para GKE
- Secret Manager access

### Integração
- GitHub Actions ready
- Cloud Build compatible
- Atlantis support

## 💰 Otimização de Custos

### Desenvolvimento
- Instâncias menores
- Preemptible VMs
- Lifecycle policies agressivas

### Produção
- Committed use discounts
- Right-sizing de recursos
- Monitoring de custos

## 🔧 Manutenção

### Updates
- GKE auto-upgrade
- OS patches automáticos
- Security updates

### Monitoring
- Health checks
- Alerting
- Logging

### Backup
- Automated backups
- Disaster recovery
- Testing procedures

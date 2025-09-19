# Terraform GCP Infrastructure Template

Este repositório contém uma estrutura completa de infraestrutura como código para Google Cloud Platform (GCP) usando Terraform, seguindo as melhores práticas de provisionamento e organização modular.

## 🏗️ Arquitetura

A infraestrutura inclui:

- **VPC Custom** com subnets públicas e privadas
- **GKE Cluster** com node pools e workload identity
- **Cloud SQL** (PostgreSQL) com IP privado
- **Cloud Storage** buckets públicos e privados
- **Load Balancer HTTP(S)** com certificado SSL gerenciado
- **IAM** com Service Accounts e permissões mínimas
- **VM Bastion** para acesso seguro
- **Project Management** via Terraform

## 📁 Estrutura de Diretórios

```
terraform-gcp-infra/
├── envs/                    # Ambientes (dev, staging, prod)
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/                 # Módulos reutilizáveis
│   ├── network/
│   ├── gke/
│   ├── sql/
│   ├── storage/
│   ├── loadbalancer/
│   ├── iam/
│   ├── vm/
│   └── project/
├── scripts/                 # Scripts auxiliares
├── .gitignore
└── README.md
```

## 🚀 Quick Start

### Pré-requisitos

1. **Terraform** >= 1.5.0
2. **Google Cloud SDK** instalado e configurado
3. **Projeto GCP** com billing habilitado
4. **Service Account** com permissões adequadas

### Configuração Inicial

1. Clone o repositório:
```bash
git clone <repository-url>
cd terraform-gcp-infra
```

2. Configure as variáveis:
```bash
cd envs/prod
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus valores
```

3. Inicialize o Terraform:
```bash
terraform init
```

4. Planeje a infraestrutura:
```bash
terraform plan
```

5. Aplique a infraestrutura:
```bash
terraform apply
```

## 🔧 Configuração por Ambiente

### Desenvolvimento
```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

### Homologação (Staging)
```bash
cd envs/staging
terraform init
terraform plan
terraform apply
```

### Produção
```bash
cd envs/prod
terraform init
terraform plan
terraform apply
```

## 📋 Variáveis Principais

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `project_id` | ID do projeto GCP | - |
| `region` | Região GCP | `us-central1` |
| `zone` | Zona GCP | `us-central1-a` |
| `environment` | Ambiente (dev/staging/prod) | - |

## 🔐 Segurança

- Service Accounts com permissões mínimas
- Rede privada com NAT Gateway
- Cloud SQL com IP privado
- Secrets gerenciados via Secret Manager
- Workload Identity habilitado no GKE

## 📚 Módulos Disponíveis

### Network
- VPC custom
- Subnets públicas e privadas
- Firewall rules
- Cloud NAT

### GKE
- Cluster Kubernetes
- Node pools
- Workload Identity
- Configurações de rede privada

### SQL
- Cloud SQL PostgreSQL
- IP privado
- Backup automático
- Secret Manager integration

### Storage
- Buckets públicos e privados
- Versionamento
- Lifecycle policies
- IAM bindings

### Load Balancer
- HTTP(S) Load Balancer
- SSL Certificate gerenciado
- Health checks
- NEG integration

### IAM
- Service Accounts
- IAM bindings
- Roles mínimas

### VM
- Bastion host
- SSH access
- Service Account integration

### Project
- Criação de projeto GCP
- APIs habilitadas
- Billing configuration

## 🛠️ Scripts Auxiliares

- `scripts/setup.sh` - Configuração inicial
- `scripts/validate.sh` - Validação de código
- `scripts/deploy.sh` - Deploy automatizado

## 📖 Documentação Adicional

- [Configuração de Backend](docs/backend.md)
- [Variáveis por Ambiente](docs/variables.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte

Para dúvidas ou problemas:
- Abra uma issue no GitHub
- Consulte a documentação
- Verifique os logs do Terraform

---

**Desenvolvido com ❤️ para infraestrutura como código no GCP**

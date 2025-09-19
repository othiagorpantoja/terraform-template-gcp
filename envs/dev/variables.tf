variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona GCP"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "sql_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "domain_name" {
  description = "Nome do domínio para SSL"
  type        = string
  default     = ""
}

variable "create_project" {
  description = "Criar projeto via Terraform"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Nome do projeto (se create_project = true)"
  type        = string
  default     = ""
}

variable "billing_account_id" {
  description = "ID da conta de billing (se create_project = true)"
  type        = string
  default     = ""
}

variable "org_id" {
  description = "ID da organização (se create_project = true)"
  type        = string
  default     = ""
}

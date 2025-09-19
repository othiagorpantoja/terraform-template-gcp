variable "project_name" {
  description = "Nome do projeto GCP"
  type        = string
}

variable "project_id" {
  description = "ID do projeto GCP (deve ser único globalmente)"
  type        = string
}

variable "org_id" {
  description = "ID da organização (opcional)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "ID da pasta (opcional)"
  type        = string
  default     = null
}

variable "billing_account_id" {
  description = "ID da conta de billing"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

variable "project_purpose" {
  description = "Propósito do projeto"
  type        = string
  default     = "application"
}

variable "enabled_apis" {
  description = "Lista de APIs a serem habilitadas"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

variable "disable_apis_on_destroy" {
  description = "Desabilitar APIs quando o projeto for destruído"
  type        = bool
  default     = false
}

variable "iam_bindings" {
  description = "Bindings IAM para o projeto"
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "create_project_sa" {
  description = "Criar Service Account para o projeto"
  type        = bool
  default     = true
}

variable "project_sa_roles" {
  description = "Roles para a Service Account do projeto"
  type        = list(string)
  default = [
    "roles/storage.objectViewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}

variable "create_budget" {
  description = "Criar alerta de budget"
  type        = bool
  default     = false
}

variable "budget_amount" {
  description = "Valor do budget"
  type        = string
  default     = "100"
}

variable "budget_currency" {
  description = "Moeda do budget"
  type        = string
  default     = "USD"
}

variable "budget_threshold_percent" {
  description = "Percentual de threshold para alerta de budget"
  type        = number
  default     = 0.8
}

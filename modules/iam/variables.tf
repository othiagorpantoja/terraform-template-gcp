variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

variable "k8s_namespace" {
  description = "Namespace do Kubernetes para Workload Identity"
  type        = string
  default     = "default"
}

variable "k8s_service_account_name" {
  description = "Nome da Service Account do Kubernetes"
  type        = string
  default     = "app-sa"
}

variable "create_cicd_sa" {
  description = "Criar Service Account para CI/CD"
  type        = bool
  default     = true
}

variable "custom_roles" {
  description = "Roles customizadas a serem criadas"
  type = map(object({
    title       = string
    description = string
    permissions = list(string)
  }))
  default = {}
}

variable "custom_role_bindings" {
  description = "Bindings para roles customizadas"
  type = map(object({
    member = string
  }))
  default = {}
}

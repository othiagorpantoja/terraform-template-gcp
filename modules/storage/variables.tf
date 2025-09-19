variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

variable "location" {
  description = "Localização dos buckets"
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "Forçar destruição dos buckets (não usar em produção)"
  type        = bool
  default     = false
}

# Private Bucket Configuration
variable "private_versioning_enabled" {
  description = "Habilitar versionamento no bucket privado"
  type        = bool
  default     = true
}

variable "private_lifecycle_age" {
  description = "Idade para deletar objetos no bucket privado"
  type        = number
  default     = 90
}

variable "private_nearline_age" {
  description = "Idade para mover para Nearline no bucket privado"
  type        = number
  default     = 30
}

variable "private_coldline_age" {
  description = "Idade para mover para Coldline no bucket privado"
  type        = number
  default     = 90
}

variable "private_archive_age" {
  description = "Idade para mover para Archive no bucket privado"
  type        = number
  default     = 365
}

variable "private_cors_origins" {
  description = "Origens CORS para o bucket privado"
  type        = list(string)
  default     = []
}

# Public Bucket Configuration
variable "public_versioning_enabled" {
  description = "Habilitar versionamento no bucket público"
  type        = bool
  default     = true
}

variable "public_lifecycle_age" {
  description = "Idade para deletar objetos no bucket público"
  type        = number
  default     = 30
}

variable "public_nearline_age" {
  description = "Idade para mover para Nearline no bucket público"
  type        = number
  default     = 7
}

variable "public_cors_origins" {
  description = "Origens CORS para o bucket público"
  type        = list(string)
  default     = ["*"]
}

# Backup Bucket Configuration
variable "create_backup_bucket" {
  description = "Criar bucket para backups"
  type        = bool
  default     = true
}

variable "backup_lifecycle_age" {
  description = "Idade para deletar backups"
  type        = number
  default     = 2555 # 7 anos
}

variable "backup_coldline_age" {
  description = "Idade para mover backups para Coldline"
  type        = number
  default     = 30
}

variable "backup_archive_age" {
  description = "Idade para mover backups para Archive"
  type        = number
  default     = 90
}

# Logs Bucket Configuration
variable "create_logs_bucket" {
  description = "Criar bucket para logs"
  type        = bool
  default     = true
}

variable "logs_lifecycle_age" {
  description = "Idade para deletar logs"
  type        = number
  default     = 30
}

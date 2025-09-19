variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região GCP"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

variable "network_name" {
  description = "Nome da VPC"
  type        = string
}

variable "database_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Tier da instância"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Tipo de disponibilidade"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Availability type deve ser ZONAL ou REGIONAL."
  }
}

variable "disk_type" {
  description = "Tipo do disco"
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "Disk type deve ser PD_SSD ou PD_HDD."
  }
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 20
}

variable "disk_autoresize_limit" {
  description = "Limite de auto-resize do disco em GB"
  type        = number
  default     = 100
}

variable "deletion_protection" {
  description = "Proteção contra deleção"
  type        = bool
  default     = false
}

variable "backup_start_time" {
  description = "Horário de início do backup (HH:MM)"
  type        = string
  default     = "03:00"
}

variable "backup_location" {
  description = "Localização do backup"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "Habilitar Point-in-Time Recovery"
  type        = bool
  default     = true
}

variable "transaction_log_retention_days" {
  description = "Dias de retenção do log de transações"
  type        = number
  default     = 7
}

variable "retained_backups" {
  description = "Número de backups retidos"
  type        = number
  default     = 7
}

variable "maintenance_day" {
  description = "Dia da semana para manutenção (1-7, onde 1=domingo)"
  type        = number
  default     = 7
  validation {
    condition     = var.maintenance_day >= 1 && var.maintenance_day <= 7
    error_message = "Maintenance day deve estar entre 1 e 7."
  }
}

variable "maintenance_hour" {
  description = "Hora para manutenção (0-23)"
  type        = number
  default     = 3
  validation {
    condition     = var.maintenance_hour >= 0 && var.maintenance_hour <= 23
    error_message = "Maintenance hour deve estar entre 0 e 23."
  }
}

variable "maintenance_update_track" {
  description = "Track de atualização para manutenção"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["canary", "stable"], var.maintenance_update_track)
    error_message = "Maintenance update track deve ser canary ou stable."
  }
}

variable "performance_insights_enabled" {
  description = "Habilitar Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Período de retenção do Performance Insights em dias"
  type        = number
  default     = 7
}

variable "database_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "appdb"
}

variable "database_user" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

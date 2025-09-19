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

variable "private_subnet_cidr" {
  description = "CIDR da subnet privada"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da subnet pública"
  type        = string
  default     = "10.20.0.0/16"
}

variable "pods_cidr" {
  description = "CIDR para pods do GKE"
  type        = string
  default     = "10.30.0.0/16"
}

variable "services_cidr" {
  description = "CIDR para serviços do GKE"
  type        = string
  default     = "10.40.0.0/16"
}

variable "ssh_source_ranges" {
  description = "Ranges de IP permitidos para SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

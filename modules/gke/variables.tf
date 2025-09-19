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

variable "subnetwork_name" {
  description = "Nome da subnet privada"
  type        = string
}

variable "pods_range_name" {
  description = "Nome do range de pods"
  type        = string
}

variable "services_range_name" {
  description = "Nome do range de serviços"
  type        = string
}

variable "service_account_email" {
  description = "Email da Service Account para os nodes"
  type        = string
}

variable "node_count" {
  description = "Número inicial de nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Tipo de máquina para os nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Tipo do disco"
  type        = string
  default     = "pd-standard"
}

variable "min_node_count" {
  description = "Número mínimo de nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nodes"
  type        = number
  default     = 10
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block para o master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "Redes autorizadas para acessar o master"
  type        = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
}

variable "release_channel" {
  description = "Canal de release do GKE"
  type        = string
  default     = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel deve ser RAPID, REGULAR ou STABLE."
  }
}

# System Node Pool Variables
variable "create_system_node_pool" {
  description = "Criar node pool separado para workloads do sistema"
  type        = bool
  default     = false
}

variable "system_node_count" {
  description = "Número de nodes do sistema"
  type        = number
  default     = 1
}

variable "system_machine_type" {
  description = "Tipo de máquina para nodes do sistema"
  type        = string
  default     = "e2-small"
}

variable "system_disk_size_gb" {
  description = "Tamanho do disco para nodes do sistema"
  type        = number
  default     = 50
}

variable "system_disk_type" {
  description = "Tipo do disco para nodes do sistema"
  type        = string
  default     = "pd-standard"
}

variable "system_min_node_count" {
  description = "Número mínimo de nodes do sistema"
  type        = number
  default     = 1
}

variable "system_max_node_count" {
  description = "Número máximo de nodes do sistema"
  type        = number
  default     = 3
}

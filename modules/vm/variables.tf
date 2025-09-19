variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região GCP"
  type        = string
}

variable "zone" {
  description = "Zona GCP"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

variable "instance_name" {
  description = "Nome da instância"
  type        = string
  default     = "vm"
}

variable "instance_type" {
  description = "Tipo da instância (bastion, app, etc.)"
  type        = string
  default     = "bastion"
}

variable "subnetwork" {
  description = "Nome da subnet"
  type        = string
}

variable "network_name" {
  description = "Nome da VPC"
  type        = string
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Imagem da VM"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Tipo do disco"
  type        = string
  default     = "pd-standard"
}

variable "ssh_username" {
  description = "Usuário SSH"
  type        = string
  default     = "admin"
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "public_ip_enabled" {
  description = "Habilitar IP público"
  type        = bool
  default     = true
}

variable "create_static_ip" {
  description = "Criar IP estático"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags da instância"
  type        = list(string)
  default     = ["ssh"]
}

variable "service_account_email" {
  description = "Email da Service Account"
  type        = string
}

variable "service_account_scopes" {
  description = "Escopos da Service Account"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "startup_script" {
  description = "Script de inicialização"
  type        = string
  default     = ""
}

variable "preemptible" {
  description = "Usar instância preemptível"
  type        = bool
  default     = false
}

variable "enable_secure_boot" {
  description = "Habilitar Secure Boot"
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Habilitar vTPM"
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Habilitar Integrity Monitoring"
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Ranges de IP permitidos para SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_http" {
  description = "Permitir tráfego HTTP"
  type        = bool
  default     = false
}

variable "allow_https" {
  description = "Permitir tráfego HTTPS"
  type        = bool
  default     = false
}

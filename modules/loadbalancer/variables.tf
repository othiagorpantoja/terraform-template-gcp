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
  description = "Nome da subnet"
  type        = string
}

variable "k8s_service_name" {
  description = "Nome do serviço Kubernetes"
  type        = string
}

# Health Check Configuration
variable "health_check_interval" {
  description = "Intervalo do health check em segundos"
  type        = number
  default     = 5
}

variable "health_check_timeout" {
  description = "Timeout do health check em segundos"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Threshold para considerar saudável"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Threshold para considerar não saudável"
  type        = number
  default     = 3
}

variable "health_check_port" {
  description = "Porta do health check"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Caminho do health check"
  type        = string
  default     = "/"
}

variable "health_check_logging" {
  description = "Habilitar logging do health check"
  type        = bool
  default     = true
}

# Backend Service Configuration
variable "backend_timeout" {
  description = "Timeout do backend em segundos"
  type        = number
  default     = 30
}

variable "session_affinity" {
  description = "Tipo de session affinity"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "CLIENT_IP", "GENERATED_COOKIE", "HTTP_COOKIE", "CLIENT_IP_PORT_PROTO"], var.session_affinity)
    error_message = "Session affinity deve ser um dos valores válidos."
  }
}

variable "backend_logging" {
  description = "Habilitar logging do backend"
  type        = bool
  default     = true
}

variable "backend_log_sample_rate" {
  description = "Taxa de amostragem do log do backend"
  type        = number
  default     = 1.0
}

# HTTPS Configuration
variable "enable_https" {
  description = "Habilitar HTTPS"
  type        = bool
  default     = true
}

variable "ssl_domains" {
  description = "Domínios para o certificado SSL"
  type        = list(string)
  default     = []
}

# URL Map Configuration
variable "host_rules" {
  description = "Regras de host para o URL map"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_matchers" {
  description = "Path matchers para o URL map"
  type = list(object({
    name            = string
    default_service = string
    path_rules = list(object({
      paths   = list(string)
      service = string
    }))
  }))
  default = []
}

# Project Module (optional)
module "project" {
  count = var.create_project ? 1 : 0

  source = "../../modules/project"

  project_name        = var.project_name
  project_id          = var.project_id
  billing_account_id  = var.billing_account_id
  org_id              = var.org_id
  environment         = var.environment
  project_purpose     = "production"
  create_budget       = true
  budget_amount       = "500"
  budget_threshold_percent = 0.8
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_id                = var.create_project ? module.project[0].project_id : var.project_id
  environment               = var.environment
  k8s_namespace             = "default"
  k8s_service_account_name  = "app-sa"
  create_cicd_sa            = true
}

# Network Module
module "network" {
  source = "../../modules/network"

  project_id            = var.create_project ? module.project[0].project_id : var.project_id
  region                = var.region
  environment           = var.environment
  private_subnet_cidr   = "10.10.0.0/16"
  public_subnet_cidr    = "10.20.0.0/16"
  pods_cidr            = "10.30.0.0/16"
  services_cidr        = "10.40.0.0/16"
  ssh_source_ranges    = ["0.0.0.0/0"] # Configure com seu IP específico em produção
}

# GKE Module
module "gke" {
  source = "../../modules/gke"

  project_id                = var.create_project ? module.project[0].project_id : var.project_id
  region                    = var.region
  environment               = var.environment
  network_name              = module.network.vpc_name
  subnetwork_name           = module.network.private_subnet_name
  pods_range_name           = module.network.pods_range_name
  services_range_name       = module.network.services_range_name
  service_account_email     = module.iam.gke_service_account_email
  node_count                = 3
  machine_type              = "e2-medium"
  min_node_count            = 1
  max_node_count            = 10
  create_system_node_pool   = true
  system_node_count         = 1
  system_machine_type       = "e2-small"
  master_ipv4_cidr_block    = "172.16.0.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
}

# Cloud SQL Module
module "sql" {
  source = "../../modules/sql"

  project_id                        = var.create_project ? module.project[0].project_id : var.project_id
  region                            = var.region
  environment                       = var.environment
  network_name                      = module.network.vpc_name
  database_version                  = "POSTGRES_15"
  tier                             = "db-custom-1-3840" # 1 vCPU, 3.75GB RAM
  availability_type                = "REGIONAL"
  disk_type                        = "PD_SSD"
  disk_size                        = 100
  deletion_protection              = true
  point_in_time_recovery_enabled   = true
  performance_insights_enabled     = true
  database_name                    = "appdb"
  database_user                    = "admin"
  database_password                = var.sql_password
}

# Storage Module
module "storage" {
  source = "../../modules/storage"

  project_id                = var.create_project ? module.project[0].project_id : var.project_id
  environment               = var.environment
  location                  = "US"
  force_destroy             = false
  create_backup_bucket      = true
  create_logs_bucket        = true
  private_lifecycle_age     = 90
  public_lifecycle_age      = 30
  backup_lifecycle_age      = 2555 # 7 anos
  logs_lifecycle_age        = 30
}

# Load Balancer Module
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_id        = var.create_project ? module.project[0].project_id : var.project_id
  region            = var.region
  environment       = var.environment
  network_name      = module.network.vpc_name
  subnetwork_name   = module.network.private_subnet_name
  k8s_service_name  = "app-service"
  enable_https      = var.domain_name != ""
  ssl_domains       = var.domain_name != "" ? [var.domain_name] : []
  backend_timeout   = 30
  health_check_path = "/health"
}

# VM Module (Bastion Host)
module "vm" {
  source = "../../modules/vm"

  project_id              = var.create_project ? module.project[0].project_id : var.project_id
  region                  = var.region
  zone                    = var.zone
  environment             = var.environment
  instance_name           = "bastion"
  instance_type           = "bastion"
  subnetwork              = module.network.public_subnet_name
  network_name            = module.network.vpc_name
  machine_type            = "e2-small"
  image                   = "projects/debian-cloud/global/images/family/debian-11"
  disk_size               = 20
  ssh_username            = "admin"
  ssh_public_key_path     = var.ssh_public_key_path
  public_ip_enabled       = true
  create_static_ip        = true
  service_account_email   = module.iam.app_service_account_email
  preemptible             = false
  enable_secure_boot      = true
  enable_vtpm             = true
  enable_integrity_monitoring = true
  ssh_source_ranges       = ["0.0.0.0/0"] # Configure com seu IP específico em produção
}

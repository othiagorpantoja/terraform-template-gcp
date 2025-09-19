# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.environment}-gke-cluster"
  location = var.region
  project  = var.project_id

  network    = var.network_name
  subnetwork = var.subnetwork_name

  remove_default_node_pool = true
  initial_node_count       = 1

  # Logging and Monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # IP Allocation Policy
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
    use_ip_aliases                = true
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private Cluster Configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Master Authorized Networks
  master_authorized_networks_config {
    cidr_blocks = var.master_authorized_networks
  }

  # Release Channel
  release_channel {
    channel = var.release_channel
  }

  # Network Policy
  network_policy {
    enabled = true
  }

  # Addons Config
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    
    http_load_balancing {
      disabled = false
    }
    
    network_policy_config {
      disabled = false
    }
  }

  # Maintenance Policy
  maintenance_policy {
    recurring_window {
      start_time = "2023-01-01T03:00:00Z"
      end_time   = "2023-01-01T05:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  depends_on = [
    var.subnetwork_name
  ]
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.environment}-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  project    = var.project_id
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # OAuth Scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Labels
    labels = {
      environment = var.environment
      node-pool   = "primary"
    }

    # Tags
    tags = ["gke-node", var.environment]

    # Service Account
    service_account = var.service_account_email

    # Image Type
    image_type = "COS_CONTAINERD"

    # Workload Metadata Config
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded Instance Config
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Management
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Autoscaling
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Upgrade Settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# Additional Node Pool for System Workloads
resource "google_container_node_pool" "system_nodes" {
  count = var.create_system_node_pool ? 1 : 0

  name       = "${var.environment}-system-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  project    = var.project_id
  node_count = var.system_node_count

  node_config {
    machine_type = var.system_machine_type
    disk_size_gb = var.system_disk_size_gb
    disk_type    = var.system_disk_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
      node-pool   = "system"
    }

    tags = ["gke-node", "system", var.environment]

    service_account = var.service_account_email
    image_type      = "COS_CONTAINERD"

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    taint {
      key    = "node-role.kubernetes.io/system"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.system_min_node_count
    max_node_count = var.system_max_node_count
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

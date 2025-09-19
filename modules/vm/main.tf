# Compute Instance
resource "google_compute_instance" "default" {
  name         = "${var.environment}-${var.instance_name}"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {
      nat_ip = var.public_ip_enabled ? null : ""
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = var.startup_script

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  labels = {
    environment = var.environment
    instance-type = var.instance_type
  }

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }

  # Shielded VM
  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }
}

# Static IP (if requested)
resource "google_compute_address" "static_ip" {
  count = var.create_static_ip ? 1 : 0

  name   = "${var.environment}-${var.instance_name}-ip"
  region = var.region
  project = var.project_id
}

# Attach static IP to instance
resource "google_compute_instance" "with_static_ip" {
  count = var.create_static_ip ? 1 : 0

  name         = "${var.environment}-${var.instance_name}"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {
      nat_ip = google_compute_address.static_ip[0].address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = var.startup_script

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  labels = {
    environment = var.environment
    instance-type = var.instance_type
  }

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }
}

# Firewall Rule for SSH (if public IP is enabled)
resource "google_compute_firewall" "allow_ssh" {
  count = var.public_ip_enabled ? 1 : 0

  name    = "${var.environment}-${var.instance_name}-allow-ssh"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh"]
}

# Firewall Rule for HTTP (if enabled)
resource "google_compute_firewall" "allow_http" {
  count = var.allow_http ? 1 : 0

  name    = "${var.environment}-${var.instance_name}-allow-http"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

# Firewall Rule for HTTPS (if enabled)
resource "google_compute_firewall" "allow_https" {
  count = var.allow_https ? 1 : 0

  name    = "${var.environment}-${var.instance_name}-allow-https"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}

# Global Address for Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name         = "${var.environment}-lb-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Health Check
resource "google_compute_health_check" "default" {
  name               = "${var.environment}-http-health-check"
  project            = var.project_id
  check_interval_sec = var.health_check_interval
  timeout_sec        = var.health_check_timeout
  healthy_threshold  = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
    proxy_header = "NONE"
  }

  log_config {
    enable = var.health_check_logging
  }
}

# Network Endpoint Group (NEG)
resource "google_compute_region_network_endpoint_group" "gke_neg" {
  name                  = "${var.environment}-gke-neg"
  network_endpoint_type = "GCE_VM_IP_PORT"
  region                = var.region
  project               = var.project_id
  network               = var.network_name
  subnetwork            = var.subnetwork_name

  cloud_run {
    service = var.k8s_service_name
  }
}

# Backend Service
resource "google_compute_backend_service" "default" {
  name                  = "${var.environment}-backend-service"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = var.backend_timeout
  health_checks         = [google_compute_health_check.default.id]
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = var.session_affinity

  backend {
    group = google_compute_region_network_endpoint_group.gke_neg.id
  }

  log_config {
    enable      = var.backend_logging
    sample_rate = var.backend_log_sample_rate
  }

  depends_on = [google_compute_region_network_endpoint_group.gke_neg]
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = "${var.environment}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.default.id

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_matchers
    content {
      name            = path_matcher.value.name
      default_service = path_matcher.value.default_service

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.service
        }
      }
    }
  }
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.environment}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
}

# Global Forwarding Rule for HTTP
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.environment}-http-forwarding-rule"
  project    = var.project_id
  ip_address = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
  port_range  = "80"
  target      = google_compute_target_http_proxy.default.id
}

# SSL Certificate (if HTTPS is enabled)
resource "google_compute_managed_ssl_certificate" "default" {
  count = var.enable_https ? 1 : 0

  name    = "${var.environment}-ssl-cert"
  project = var.project_id

  managed {
    domains = var.ssl_domains
  }
}

# Target HTTPS Proxy (if HTTPS is enabled)
resource "google_compute_target_https_proxy" "default" {
  count = var.enable_https ? 1 : 0

  name    = "${var.environment}-https-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

# Global Forwarding Rule for HTTPS (if HTTPS is enabled)
resource "google_compute_global_forwarding_rule" "https" {
  count = var.enable_https ? 1 : 0

  name       = "${var.environment}-https-forwarding-rule"
  project    = var.project_id
  ip_address = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
  port_range  = "443"
  target      = google_compute_target_https_proxy.default[0].id
}

# Firewall Rule for Health Checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.environment}-allow-health-checks"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [var.health_check_port]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["gke-node"]
}

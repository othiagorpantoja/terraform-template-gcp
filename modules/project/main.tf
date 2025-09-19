# Google Cloud Project
resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    purpose     = var.project_purpose
  }
}

# Enable required APIs
resource "google_project_service" "enabled_apis" {
  for_each = toset(var.enabled_apis)

  project = google_project.project.project_id
  service = each.key

  disable_on_destroy = var.disable_apis_on_destroy

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# Project IAM Policy
resource "google_project_iam_policy" "project_policy" {
  count = length(var.iam_bindings) > 0 ? 1 : 0

  project     = google_project.project.project_id
  policy_data = data.google_iam_policy.project_policy[0].policy_data

  depends_on = [google_project_service.enabled_apis]
}

data "google_iam_policy" "project_policy" {
  count = length(var.iam_bindings) > 0 ? 1 : 0

  dynamic "binding" {
    for_each = var.iam_bindings
    content {
      role    = binding.value.role
      members = binding.value.members
    }
  }
}

# Project Service Account
resource "google_service_account" "project_sa" {
  count = var.create_project_sa ? 1 : 0

  account_id   = "${var.environment}-project-sa"
  display_name = "Project Service Account - ${var.environment}"
  description  = "Service Account para o projeto ${var.project_name}"
  project      = google_project.project.project_id
}

# Project Service Account IAM Bindings
resource "google_project_iam_member" "project_sa_roles" {
  for_each = var.create_project_sa ? toset(var.project_sa_roles) : []

  project = google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.project_sa[0].email}"
}

# Budget Alert (if configured)
resource "google_billing_budget" "budget" {
  count = var.create_budget ? 1 : 0

  billing_account = var.billing_account_id
  display_name    = "${var.project_name} Budget"

  budget_filter {
    projects = ["projects/${google_project.project.number}"]
  }

  amount {
    specified_amount {
      currency_code = var.budget_currency
      units         = var.budget_amount
    }
  }

  threshold_rules {
    threshold_percent = var.budget_threshold_percent
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }
}

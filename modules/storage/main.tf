# Private Bucket
resource "google_storage_bucket" "private" {
  name          = "${var.project_id}-${var.environment}-private"
  location      = var.location
  force_destroy = var.force_destroy
  project       = var.project_id

  uniform_bucket_level_access = true
  
  versioning {
    enabled = var.private_versioning_enabled
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.private_lifecycle_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = var.private_nearline_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = var.private_coldline_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      age = var.private_archive_age
    }
  }

  cors {
    origin          = var.private_cors_origins
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  labels = {
    environment = var.environment
    visibility  = "private"
    purpose     = "application-data"
  }
}

# Public Bucket
resource "google_storage_bucket" "public" {
  name          = "${var.project_id}-${var.environment}-public"
  location      = var.location
  force_destroy = var.force_destroy
  project       = var.project_id

  uniform_bucket_level_access = true
  
  versioning {
    enabled = var.public_versioning_enabled
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.public_lifecycle_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = var.public_nearline_age
    }
  }

  cors {
    origin          = var.public_cors_origins
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  labels = {
    environment = var.environment
    visibility  = "public"
    purpose     = "static-assets"
  }
}

# IAM Binding for Public Bucket
resource "google_storage_bucket_iam_binding" "public_access" {
  bucket = google_storage_bucket.public.name
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# Backup Bucket
resource "google_storage_bucket" "backup" {
  count = var.create_backup_bucket ? 1 : 0

  name          = "${var.project_id}-${var.environment}-backup"
  location      = var.location
  force_destroy = var.force_destroy
  project       = var.project_id

  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.backup_lifecycle_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = var.backup_coldline_age
    }
  }

  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      age = var.backup_archive_age
    }
  }

  labels = {
    environment = var.environment
    visibility  = "private"
    purpose     = "backups"
  }
}

# Logs Bucket
resource "google_storage_bucket" "logs" {
  count = var.create_logs_bucket ? 1 : 0

  name          = "${var.project_id}-${var.environment}-logs"
  location      = var.location
  force_destroy = var.force_destroy
  project       = var.project_id

  uniform_bucket_level_access = true
  
  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.logs_lifecycle_age
    }
  }

  labels = {
    environment = var.environment
    visibility  = "private"
    purpose     = "logs"
  }
}

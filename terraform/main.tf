terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "mental-health-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "mental-health-bq" {
  dataset_id = var.bq_dataset_name
  location   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "dbt-staging-bq" {
  dataset_id = dbt_mental_health
  location   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "dbt-prod-bq" {
  dataset_id = mental_health_prod
  location   = var.location
  delete_contents_on_destroy = true
}

resource "google_compute_instance" "de-zoomcamp-project-vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.region

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240229"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }
}

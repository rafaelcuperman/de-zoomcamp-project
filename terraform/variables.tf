variable "credentials" {
  description = "My Credentials"
  default     = "../.cred.json"
}

variable "project" {
  description = "Project"
  default     = "de-zoomcamp-project-416612"
}

variable "region" {
  description = "Region"
  default     = "europe-west4-a"
}

variable "location" {
  description = "Project Location"
  default     = "europe-west4"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "mental_health"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "mental-health-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

variable "vm_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "vm_name" {
  type    = string
  default = "de-zoomcamp-project-vm"
}
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west1-b"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "provedcode"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-medium"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "provedcode"
}

variable "postgres_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "provedcode"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access infrastructure"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

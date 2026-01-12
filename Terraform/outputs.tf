output "backend_ip" {
  description = "Backend external IP"
  value       = google_compute_instance.backend.network_interface[0].access_config[0].nat_ip
}

output "backend_url" {
  description = "Backend URL"
  value       = "http://${google_compute_instance.backend.network_interface[0].access_config[0].nat_ip}:8083"
}

output "frontend_ip" {
  description = "Frontend external IP"
  value       = google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip}"
}

output "postgres_connection" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@${google_sql_database_instance.postgres.public_ip_address}:5432/${var.postgres_db}"
  sensitive   = true
}

output "postgres_ip" {
  description = "PostgreSQL public IP"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "backend_internal_ip" {
  description = "Backend internal IP"
  value       = google_compute_instance.backend.network_interface[0].network_ip
}

output "frontend_internal_ip" {
  description = "Frontend internal IP"
  value       = google_compute_instance.frontend.network_interface[0].network_ip
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    backend  = "gcloud compute ssh ${google_compute_instance.backend.name} --zone=${var.gcp_zone}"
    frontend = "gcloud compute ssh ${google_compute_instance.frontend.name} --zone=${var.gcp_zone}"
  }
}

output "deployment_info" {
  description = "Information for CI/CD deployment"
  value = {
    backend_ip  = google_compute_instance.backend.network_interface[0].access_config[0].nat_ip
    frontend_ip = google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip
    db_host     = google_sql_database_instance.postgres.public_ip_address
    db_name     = var.postgres_db
    db_user     = var.postgres_user
  }
}

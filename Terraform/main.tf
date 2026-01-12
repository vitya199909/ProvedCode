# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-allow-http-https"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["web"]
}

resource "google_compute_firewall" "allow_backend" {
  name    = "${var.project_name}-allow-backend"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8083"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["backend"]
}

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_name}-db-${var.environment}"
  database_version = "POSTGRES_15"
  region           = var.gcp_region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = var.postgres_db
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "user" {
  name     = var.postgres_user
  instance = google_sql_database_instance.postgres.name
  password = var.postgres_password
}

# Backend VM
resource "google_compute_instance" "backend" {
  name         = "${var.project_name}-backend"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["ssh", "backend"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    enable-oslogin = "FALSE"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io openjdk-17-jdk maven
    systemctl start docker
    systemctl enable docker
    
    # Create user if not exists
    if ! id -u viktor &>/dev/null; then
        useradd -m -s /bin/bash viktor
        usermod -aG sudo,docker viktor
        echo "viktor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    
    # Application will be deployed by Jenkins/Ansible
    mkdir -p /opt/provedcode
    chown -R viktor:viktor /opt/provedcode
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_sql_database_instance.postgres]
}

# Frontend VM
resource "google_compute_instance" "frontend" {
  name         = "${var.project_name}-frontend"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["ssh", "web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    enable-oslogin = "FALSE"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io nginx nodejs npm
    systemctl start docker
    systemctl enable docker
    systemctl start nginx
    systemctl enable nginx
    
    # Create user if not exists
    if ! id -u viktor &>/dev/null; then
        useradd -m -s /bin/bash viktor
        usermod -aG sudo,docker viktor
        echo "viktor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    
    # Configure nginx as reverse proxy
    cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://${google_compute_instance.backend.network_interface[0].network_ip}:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX
    
    systemctl reload nginx
    
    # Application will be deployed by Jenkins/Ansible
    mkdir -p /opt/provedcode /var/www/html
    chown -R viktor:viktor /opt/provedcode
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_instance.backend]
}

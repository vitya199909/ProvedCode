#!/bin/bash
set -e

# Set SELinux to permissive mode
echo "Setting SELinux to permissive mode..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Install Docker
echo "Installing Docker..."
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker vagrant

# Configure firewall
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-service=postgresql
sudo firewall-cmd --reload

# Start PostgreSQL container
echo "Starting PostgreSQL container..."
sudo docker run -d --name postgres \
  --restart=always \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 postgres:17

echo "Database setup completed!"

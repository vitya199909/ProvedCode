#!/bin/bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker vagrant
docker run -d --name postgres \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 postgres:17

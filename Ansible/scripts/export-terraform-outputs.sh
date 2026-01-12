#!/bin/bash

# Export Terraform outputs as environment variables for Ansible
# Usage: source ./scripts/export-terraform-outputs.sh

TERRAFORM_DIR="../Terraform"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found at $TERRAFORM_DIR"
    exit 1
fi

cd "$TERRAFORM_DIR"

echo "Exporting Terraform outputs..."

export BACKEND_IP=$(terraform output -raw backend_ip 2>/dev/null)
export FRONTEND_IP=$(terraform output -raw frontend_ip 2>/dev/null)
export BACKEND_INTERNAL_IP=$(terraform output -raw backend_internal_ip 2>/dev/null)
export DB_HOST=$(terraform output -raw postgres_ip 2>/dev/null)
export DB_NAME=$(terraform output -json deployment_info 2>/dev/null | jq -r '.db_name')
export DB_USER=$(terraform output -json deployment_info 2>/dev/null | jq -r '.db_user')

# Read password from terraform.tfvars
export DB_PASSWORD=$(grep postgres_password terraform.tfvars | cut -d'=' -f2 | tr -d ' "')

echo "Environment variables set:"
echo "  BACKEND_IP=$BACKEND_IP"
echo "  FRONTEND_IP=$FRONTEND_IP"
echo "  BACKEND_INTERNAL_IP=$BACKEND_INTERNAL_IP"
echo "  DB_HOST=$DB_HOST"
echo "  DB_NAME=$DB_NAME"
echo "  DB_USER=$DB_USER"
echo "  DB_PASSWORD=***"

cd - > /dev/null

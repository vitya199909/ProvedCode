#!/bin/bash

# Setup SSH for GCP VMs
# This script adds your SSH public key to GCP VMs

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Setting up SSH for GCP VMs ===${NC}"

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${YELLOW}SSH key not found. Generating new key...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Get VM IPs from Terraform
cd ../Terraform

BACKEND_IP=$(terraform output -raw backend_ip 2>/dev/null)
FRONTEND_IP=$(terraform output -raw frontend_ip 2>/dev/null)
GCP_ZONE=$(terraform output -json ssh_commands 2>/dev/null | jq -r '.backend' | grep -oP 'zone=\K[^ ]+')

if [ -z "$BACKEND_IP" ] || [ -z "$FRONTEND_IP" ]; then
    echo -e "${RED}Error: Could not get VM IPs from Terraform${NC}"
    exit 1
fi

echo -e "${GREEN}Found VMs:${NC}"
echo "  Backend:  $BACKEND_IP"
echo "  Frontend: $FRONTEND_IP"
echo ""

# Function to add SSH key to VM
add_ssh_key() {
    local VM_NAME=$1
    local VM_IP=$2
    
    echo -e "${YELLOW}Adding SSH key to $VM_NAME...${NC}"
    
    # Using gcloud to add SSH key
    gcloud compute ssh $VM_NAME --zone=$GCP_ZONE --command="
        sudo mkdir -p /home/viktor/.ssh
        echo '$SSH_KEY' | sudo tee -a /home/viktor/.ssh/authorized_keys > /dev/null
        sudo chown -R viktor:viktor /home/viktor/.ssh
        sudo chmod 700 /home/viktor/.ssh
        sudo chmod 600 /home/viktor/.ssh/authorized_keys
    " 2>/dev/null || {
        echo -e "${RED}Failed to add key via gcloud, trying direct SSH...${NC}"
        
        # Alternative: add via metadata
        gcloud compute instances add-metadata $VM_NAME \
            --zone=$GCP_ZONE \
            --metadata "ssh-keys=viktor:$SSH_KEY"
    }
    
    echo -e "${GREEN}✓ SSH key added to $VM_NAME${NC}"
}

# Add SSH keys to both VMs
add_ssh_key "provedcode-backend" "$BACKEND_IP"
add_ssh_key "provedcode-frontend" "$FRONTEND_IP"

cd ../Ansible

echo ""
echo -e "${GREEN}=== Testing SSH connection ===${NC}"

# Test SSH
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 viktor@$BACKEND_IP "echo 'Backend connection successful'" && \
    echo -e "${GREEN}✓ Backend SSH working${NC}" || \
    echo -e "${RED}✗ Backend SSH failed${NC}"

ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 viktor@$FRONTEND_IP "echo 'Frontend connection successful'" && \
    echo -e "${GREEN}✓ Frontend SSH working${NC}" || \
    echo -e "${RED}✗ Frontend SSH failed${NC}"

echo ""
echo -e "${GREEN}=== Testing Ansible ===${NC}"
ansible all -m ping

echo ""
echo -e "${GREEN}Setup complete!${NC}"

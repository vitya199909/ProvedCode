#!/bin/bash

# Setup GitHub Secrets from local environment
# Usage: ./setup-secrets.sh

set -e

echo "🔐 Setting up GitHub Secrets..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "Install: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

# GCP Project ID
echo "Setting GCP_PROJECT_ID..."
gh secret set GCP_PROJECT_ID -b "robotic-haven-459022-i7"

# SSH Keys
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "Setting SSH_PRIVATE_KEY..."
    gh secret set SSH_PRIVATE_KEY < ~/.ssh/id_ed25519
    
    echo "Setting SSH_PUBLIC_KEY..."
    gh secret set SSH_PUBLIC_KEY < ~/.ssh/id_ed25519.pub
else
    echo "⚠️  SSH key not found at ~/.ssh/id_ed25519"
fi

# Database secrets
echo "Setting DB_NAME..."
gh secret set DB_NAME -b "provedcode"

echo "Setting DB_USER..."
gh secret set DB_USER -b "provedcode"

echo ""
echo "⚠️  Manual steps required:"
echo ""
echo "1. Create GCP Service Account and download key.json:"
echo "   gcloud iam service-accounts create github-actions --display-name='GitHub Actions'"
echo "   gcloud iam service-accounts keys create key.json --iam-account=github-actions@robotic-haven-459022-i7.iam.gserviceaccount.com"
echo "   gh secret set GCP_SA_KEY < key.json"
echo ""
echo "2. Set database password:"
echo "   gh secret set DB_PASSWORD -b 'your-secure-password'"
echo ""
echo "3. Get DB host from Terraform:"
echo "   cd Terraform"
echo "   terraform output -raw postgres_ip"
echo "   gh secret set DB_HOST -b 'PASTE_IP_HERE'"
echo ""
echo "✅ Basic secrets configured!"

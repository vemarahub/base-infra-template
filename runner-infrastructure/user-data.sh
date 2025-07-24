#!/bin/bash

# Logging function
log() {
    echo "$(date): $1" | tee -a /var/log/runner-setup.log
}

log "Starting GitHub runner setup..."

# Update system with retries
log "Updating system packages..."
for i in {1..3}; do
    if apt-get update && apt-get upgrade -y; then
        log "System update successful"
        break
    else
        log "System update attempt $i failed, retrying..."
        sleep 30
    fi
done

# Install essential tools
log "Installing essential tools..."
apt-get install -y curl git unzip wget jq awscli || {
    log "Failed to install essential tools"
    exit 1
}

# Install Terraform
log "Installing Terraform..."
TERRAFORM_VERSION="1.6.6"
wget https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
log "Terraform installed: $(terraform --version)"

# Install Node.js
log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
log "Node.js installed: $(node --version)"

# Create runner directory
log "Creating runner directory..."
mkdir -p /home/ubuntu/actions-runner
cd /home/ubuntu/actions-runner

# Download GitHub runner with retries
log "Downloading GitHub runner..."
RUNNER_VERSION="2.311.0"
for i in {1..3}; do
    if curl -o actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz; then
        log "Runner download successful"
        break
    else
        log "Runner download attempt $i failed, retrying..."
        sleep 30
    fi
done

# Extract runner
tar xzf ./actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
rm actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/actions-runner
log "Set ownership of runner directory"

# Wait for network connectivity to GitHub
log "Testing GitHub connectivity..."
for i in {1..30}; do
    if curl -s --connect-timeout 5 https://api.github.com > /dev/null; then
        log "GitHub API is reachable"
        break
    fi
    log "Waiting for GitHub connectivity... attempt $i"
    sleep 10
done

log "GitHub runner setup completed at $$(date)"

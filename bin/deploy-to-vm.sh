#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load the configuration file (vm-deploy-config.cfg)
source ./config/vm-deploy-config.cfg

# Function to log errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Function to remove existing files on the VM
remove_existing_files_on_vm() {
    echo "Removing old webhook files on the VM..."
    gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="rm -rf $REMOTE_DIR/setup-webhook.sh $REMOTE_CONFIG_DIR/* $REMOTE_WEBHOOK_DIR/webhook.php $REMOTE_WEBHOOK_BIN/*" || error_exit "Failed to remove old webhook files on the VM."
}

# Create the remote directories on the VM
echo "Creating webhook directories on the VM..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="mkdir -p $REMOTE_CONFIG_DIR $REMOTE_WEBHOOK_DIR/logs $REMOTE_WEBHOOK_BIN" || error_exit "Failed to create webhook directories on the VM."

# Remove existing files before copying new ones
remove_existing_files_on_vm

# Copy the webhook and deploy files
echo "Copying webhook.php and deploy script to the VM..."
gcloud compute scp "$WEBHOOK_PHP" "$VM_NAME:$REMOTE_WEBHOOK_DIR" --zone="$ZONE" || error_exit "Failed to copy webhook.php to the VM."
gcloud compute scp "$DEPLOY_WEBHOOK_SCRIPT" "$VM_NAME:$REMOTE_WEBHOOK_BIN" --zone="$ZONE" || error_exit "Failed to copy deploy-webhook.sh to the VM."

# Copy the setup and Nginx config files from your machine to the VM
echo "Copying setup script to the VM..."
gcloud compute scp "$SCRIPT_PATH" "$VM_NAME:$REMOTE_DIR" --zone="$ZONE" || error_exit "Failed to copy setup script to the VM."

echo "Copying Nginx config to the VM..."
gcloud compute scp "$NGINX_CONFIG_PATH" "$VM_NAME:$REMOTE_CONFIG_DIR" --zone="$ZONE" || error_exit "Failed to copy Nginx config to the VM."

echo "Copying Nginx site template to the VM..."
gcloud compute scp "$SITE_TEMPLATE_PATH" "$VM_NAME:$REMOTE_CONFIG_DIR" --zone="$ZONE" || error_exit "Failed to copy Nginx site template to the VM."

# Run the setup script on the VM
echo "Executing setup script on the VM..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="bash $REMOTE_DIR/required-installationGCP.sh" || error_exit "Failed to execute setup script on the VM."

echo "Deployment complete!"

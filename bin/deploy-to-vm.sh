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
    echo "Removing old files on the VM..."
    gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="rm -rf $REMOTE_DIR/setup-webhook.sh $REMOTE_CONFIG_DIR/*" || error_exit "Failed to remove old files on the VM."
}

# Create the remote directories on the VM
echo "Creating remote directories on the VM..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="mkdir -p $REMOTE_CONFIG_DIR" || error_exit "Failed to create remote directories on the VM."

# Remove existing files before copying new ones
remove_existing_files_on_vm

# Copy the script and config files from your Windows machine to the VM
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

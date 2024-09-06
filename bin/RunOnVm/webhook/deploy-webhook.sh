#!/bin/bash

# Get the current user dynamically
USER=$(whoami)

# Create log file with a timestamp
LOG_FILE="/home/${USER}/webhook/logs/deploy_$(date +"%Y-%m-%d_%H-%M-%S").log"

echo "Starting deployment..." >> "$LOG_FILE"

cd /var/www/financial-calcy-cursor01 || { echo "Failed to navigate to project directory"; exit 1; }

# Pull the latest changes from the main branch
sudo git fetch --all >> "$LOG_FILE" 2>&1
sudo git reset --hard origin/main >> "$LOG_FILE" 2>&1

# Set the proper permissions (optional)
sudo chown -R www-data:www-data /var/www/financial-calcy-cursor01 >> "$LOG_FILE" 2>&1
sudo chmod -R 755 /var/www/financial-calcy-cursor01 >> "$LOG_FILE" 2>&1

echo "Deployment completed at $(date)" >> "$LOG_FILE"

# Reload Nginx to apply any changes
sudo systemctl reload nginx

# Log the deployment time
echo "Deployed on: $(date)" >> "$LOG_FILE"

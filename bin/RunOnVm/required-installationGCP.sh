#!/bin/bash

# Get the current user for log directory creation
USERNAME=$(whoami)

# Load the nginx-config.cfg configuration file
CONFIG_FILE="/home/${USERNAME}/config/nginx-config.cfg"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if email variable is set
if [ -z "$EMAIL" ]; then
    echo "Email not provided in the configuration file. Exiting."
    exit 1
fi

# Create log directory if it doesn't exist
LOG_DIR="/home/${USERNAME}/logs"
mkdir -p "$LOG_DIR"

# Generate a log file with a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/install_logs_${TIMESTAMP}.log"

# Function to log messages to the log file
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $1" | tee -a "$LOG_FILE"
}

# Log the start of the script
log "Starting the installation process..."

# Update the system and install Git, Nginx, PHP 8.2, and Certbot
log "Updating system packages..."
sudo apt update | tee -a "$LOG_FILE"

log "Installing Git, Nginx, PHP 8.2, and required packages..."
sudo apt install -y git nginx php8.2 php8.2-fpm php8.2-cli php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip certbot python3-certbot-nginx dnsutils | tee -a "$LOG_FILE"

# Enable and start Nginx
log "Enabling and starting Nginx service..."
sudo systemctl enable nginx | tee -a "$LOG_FILE"
sudo systemctl start nginx | tee -a "$LOG_FILE"

# Enable and start PHP-FPM
log "Enabling and starting PHP-FPM service..."
sudo systemctl enable php8.2-fpm | tee -a "$LOG_FILE"
sudo systemctl start php8.2-fpm | tee -a "$LOG_FILE"

# Check if GIT_CLONE_URL is provided in the config file
WEB_ROOT_PATH="/var/www/${REPO_NAME}"
if [ -n "$GIT_CLONE_URL" ]; then
    if [ ! -d "$WEB_ROOT_PATH" ]; then
        log "Cloning repository from $GIT_CLONE_URL into $WEB_ROOT_PATH..."
        if ! sudo git clone "$GIT_CLONE_URL" "$WEB_ROOT_PATH" 2>&1 | tee -a "$LOG_FILE"; then
            log "Failed to clone repository from $GIT_CLONE_URL. Exiting."
            exit 1
        fi
    else
        log "Repository already cloned: $WEB_ROOT_PATH"
    fi
else
    log "GIT_CLONE_URL not provided. Creating empty folder: $WEB_ROOT_PATH..."
    sudo mkdir -p "$WEB_ROOT_PATH" | tee -a "$LOG_FILE"
fi

# Change ownership of the web root directory
log "Setting ownership and permissions for web root directory..."
sudo chown -R www-data:www-data "$WEB_ROOT_PATH" 2>&1 | tee -a "$LOG_FILE"
sudo chmod -R 755 "$WEB_ROOT_PATH" 2>&1 | tee -a "$LOG_FILE"

# Prepare Nginx configuration file without SSL
NGINX_CONFIG_FILE="/etc/nginx/sites-available/${DOMAIN_NAME}"
TEMPLATE_FILE="/home/${USERNAME}/config/site-template-no-ssl.conf"

log "Preparing Nginx configuration file without SSL..."
if [ -f "$TEMPLATE_FILE" ]; then
    sudo mkdir -p /etc/nginx/sites-available
    sudo mkdir -p /etc/nginx/sites-enabled
    sed "s/{{DOMAIN_NAME}}/${DOMAIN_NAME}/g; s|{{WEB_ROOT_PATH}}|${WEB_ROOT_PATH}|g" "$TEMPLATE_FILE" | sudo tee "$NGINX_CONFIG_FILE" > /dev/null
else
    log "Nginx template file not found. Exiting..."
    exit 1
fi

# Create a symbolic link in sites-enabled if not already present
if [ ! -L "/etc/nginx/sites-enabled/${DOMAIN_NAME}" ]; then
    log "Creating symbolic link for Nginx configuration..."
    sudo ln -s "$NGINX_CONFIG_FILE" /etc/nginx/sites-enabled/ | tee -a "$LOG_FILE"
fi

# Test Nginx configuration before proceeding with Certbot
log "Testing Nginx configuration (without SSL)..."
if ! sudo nginx -t; then
    log "Nginx configuration failed. Exiting."
    exit 1
fi

# Reload Nginx with the non-SSL configuration
log "Reloading Nginx service..."
sudo systemctl reload nginx | tee -a "$LOG_FILE"

# Check if the domain resolves to the current server IP before Certbot
log "Checking if ${DOMAIN_NAME} resolves to the server's public IP..."

SERVER_IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(dig +short "${DOMAIN_NAME}")

if [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
    log "Domain ${DOMAIN_NAME} does not resolve to the server IP (${SERVER_IP}). Please update the DNS settings. Exiting."
    exit 1
fi

# Obtain SSL certificate using Certbot for domain (with email from config)
log "Obtaining SSL certificate with Certbot..."
if ! sudo certbot --nginx -d "${DOMAIN_NAME}" -d "www.${DOMAIN_NAME}" --email "$EMAIL" --agree-tos | tee -a "$LOG_FILE"; then
    log "Certbot failed to obtain the SSL certificate. Ensure that the domain resolves to the correct IP and try again."
    exit 1
fi

# Test Nginx configuration after Certbot updates it
log "Testing Nginx configuration (with SSL)..."
if ! sudo nginx -t; then
    log "Nginx configuration failed after SSL update. Exiting."
    exit 1
fi

# Reload Nginx with the SSL configuration
log "Reloading Nginx service (with SSL)..."
sudo systemctl reload nginx | tee -a "$LOG_FILE"

log "Installation process completed successfully."

# Output success message
echo "PHP 8.2, Nginx, and Git have been installed and configured with HTTPS." | tee -a "$LOG_FILE"
echo "Site configured for domain: ${DOMAIN_NAME}" | tee -a "$LOG_FILE"

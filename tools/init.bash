#!/bin/bash
set -e

# Get the absolute path of script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"
VOL_DIR="${SCRIPT_DIR}/../vol/"

# -------------------------------------
# KEYCLOAK setup script
# -------------------------------------

KEYCLOAK_POSTGRES_VERSION=16
KEYCLOAK_APP_VERSION=26.2.2


# Generate secure random defaults
generate_defaults() {
    POSTGRES_PASSWORD=$(openssl rand -hex 32)
    KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD=$(openssl rand -hex 32)
}

# Load existing configuration from .env file
load_existing_env() {
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
}

# Prompt user to confirm or update configuration
prompt_for_configuration() {
    echo "Please enter configuration values (press Enter to keep current/default value):"
    echo ""
    
    echo "postgres:"
    
    read -p "KEYCLOAK_POSTGRES_USER [${KEYCLOAK_POSTGRES_USER:-keycloak}]: " input
    KEYCLOAK_POSTGRES_USER=${input:-${KEYCLOAK_POSTGRES_USER:-keycloak}}

    read -p "KEYCLOAK_POSTGRES_PASSWORD [${KEYCLOAK_POSTGRES_PASSWORD:-$POSTGRES_PASSWORD}]: " input
    KEYCLOAK_POSTGRES_PASSWORD=${input:-${KEYCLOAK_POSTGRES_PASSWORD:-$POSTGRES_PASSWORD}}

    read -p "KEYCLOAK_POSTGRES_DB [${KEYCLOAK_POSTGRES_DB:-keycloak}]: " input
    KEYCLOAK_POSTGRES_DB=${input:-${KEYCLOAK_POSTGRES_DB:-keycloak}}

    echo ""
    echo "socat-smtp:"
    
    read -p "KEYCLOAK_SOCAT_SMTP_HOST [${KEYCLOAK_SOCAT_SMTP_HOST:-smtp.mailgun.org}]: " input
    KEYCLOAK_SOCAT_SMTP_HOST=${input:-${KEYCLOAK_SOCAT_SMTP_HOST:-smtp.mailgun.org}}

    read -p "KEYCLOAK_SOCAT_SMTP_PORT [${KEYCLOAK_SOCAT_SMTP_PORT:-587}]: " input
    KEYCLOAK_SOCAT_SMTP_PORT=${input:-${KEYCLOAK_SOCAT_SMTP_PORT:-587}}

    echo ""
    echo "app:"
    
    read -p "KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER [${KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER:-admin}]: " input
    KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER=${input:-${KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER:-admin}}
    
    read -p "KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD [${KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD:-$KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD}]: " input
    KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD=${input:-${KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD:-$KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD}}
    
    read -p "KEYCLOAK_APP_HOSTNAME [${KEYCLOAK_APP_HOSTNAME:-auth.example.com}]: " input
    KEYCLOAK_APP_HOSTNAME=${input:-${KEYCLOAK_APP_HOSTNAME:-auth.example.com}}
}


# Display configuration nicely and ask for user confirmation
confirm_and_save_configuration() {
    CONFIG_LINES=(
        "# postgres"
        "KEYCLOAK_POSTGRES_VERSION=${KEYCLOAK_POSTGRES_VERSION}"
        "KEYCLOAK_POSTGRES_USER=${KEYCLOAK_POSTGRES_USER}"
        "KEYCLOAK_POSTGRES_PASSWORD=${KEYCLOAK_POSTGRES_PASSWORD}"
        "KEYCLOAK_POSTGRES_DB=${KEYCLOAK_POSTGRES_DB}"
        ""
        "# SMTP settings"
        "KEYCLOAK_SOCAT_SMTP_HOST=${KEYCLOAK_SOCAT_SMTP_HOST}"
        "KEYCLOAK_SOCAT_SMTP_PORT=${KEYCLOAK_SOCAT_SMTP_PORT}"
        ""
        "# KEYCLOAK app"
        "KEYCLOAK_APP_VERSION=${KEYCLOAK_APP_VERSION}"
        "KEYCLOAK_APP_HOSTNAME=${KEYCLOAK_APP_HOSTNAME}"
        ""
        "# Secrets"
        "KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER=${KEYCLOAK_APP_BOOTSTRAP_ADMIN_USER}"
        "KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD=${KEYCLOAK_APP_BOOTSTRAP_ADMIN_PASSWORD}"
        ""
    )

    echo ""
    echo "The following environment configuration will be saved:"
    echo "-----------------------------------------------------"

    for line in "${CONFIG_LINES[@]}"; do
        echo "$line"
    done

    echo "-----------------------------------------------------"
    echo "" 

    #
    read -p "Proceed with this configuration? (y/n): " CONFIRM
    echo "" 
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Configuration aborted by user."
        echo "" 
        exit 1
    fi

    #
    printf "%s\n" "${CONFIG_LINES[@]}" > "$ENV_FILE"
    echo ".env file saved to $ENV_FILE"
    echo "" 
}

# Set up containers and initialize the database
setup_containers() {
    echo "Stopping all containers and removing volumes..."
    docker compose down -v

    echo "Clearing volume data..."
    [ -d "${VOL_DIR}" ] && rm -rf "${VOL_DIR}"/*
    mkdir -p "${VOL_DIR}keycloak-app/opt/keycloak/data" && chown 1000 "${VOL_DIR}keycloak-app/opt/keycloak/data"

    echo "Starting containers..."
    docker compose up -d

    echo "Waiting 60 seconds for services to initialize..."
    sleep 60

    echo "Done!"
    echo ""
}

# -----------------------------------
# Main logic
# -----------------------------------

# Check if .env file exists, load or generate defaults accordingly
if [ -f "$ENV_FILE" ]; then
    echo ".env file found. Loading existing configuration."
    load_existing_env
else
    echo ".env file not found. Generating defaults."
    generate_defaults
fi

# Always prompt user for configuration confirmation
prompt_for_configuration

# Ask user confirmation and save
confirm_and_save_configuration

# Run container setup
setup_containers
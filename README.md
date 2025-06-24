## Keycloak Docker Compose Deployment (with Caddy Reverse Proxy)

This repository provides a production-ready Docker Compose configuration for deploying Keycloak — an open-source identity and access management solution — with PostgreSQL as the database backend and Caddy as a reverse proxy. The setup includes automatic initialization, secure environment variable handling, and support for running behind a SOCKS5h-aware SMTP relay container.

## Setup Instructions

### 1. Clone the Repository

Clone the project to your server in the `/docker/keycloak/` directory:

```
mkdir -p /docker/keycloak
cd /docker/keycloak

# Clone the main Keycloak project
git clone https://github.com/ldev1281/docker-compose-keycloak.git .
```


### 2. Create Docker Network and Set Up Reverse Proxy

This project is designed to work with the reverse proxy configuration provided by [`docker-compose-caddy`](https://github.com/ldev1281/docker-compose-caddy). To enable this integration, follow these steps:

1. **Create the shared Docker network** (if it doesn't already exist):

   ```bash
   docker network create --driver bridge caddy-keycloak
   ```

2. **Set up the Caddy reverse proxy** by following the instructions in the [`docker-compose-caddy`](https://github.com/ldev1281/docker-compose-caddy).  

Once Caddy is installed, it will automatically detect the Keycloak container via the `caddy-keycloak` network and route traffic accordingly.


### 3. Configure and Start the Application

To configure and launch all required services, run the provided script:

```bash
./tools/init.bash
```

The script will:

- Prompt you to enter configuration values (press `Enter` to accept defaults).
- Generate secure random secrets automatically.
- Save all settings to the `.env` file located at the project root.

**Important:**  
Make sure to securely store your `.env` file locally for future reference or redeployment.


### 4. Verify Running Containers

Check if all containers are running properly:

```bash
docker ps
```

Your Keycloak instance should now be operational.

## Creating a Backup Task for Keycloak

To create a backup task for your Keycloak deployment using [`backup-tool`](https://github.com/ldev1281/backup-tool), add a new task file to `/etc/limbo-backup/rsync.conf.d/`:

```bash
sudo nano /etc/limbo-backup/rsync.conf.d/20-keycloak.conf.bash
```

Paste the following contents:

```bash
CMD_BEFORE_BACKUP="docker compose --project-directory /docker/keycloak down"
CMD_AFTER_BACKUP="docker compose --project-directory /docker/keycloak up -d"

INCLUDE_PATHS=(
  "/docker/keycloak/.env"
  "/docker/keycloak/vol"
)
```


## License

Licensed under the Prostokvashino License. See [LICENSE](LICENSE) for details.
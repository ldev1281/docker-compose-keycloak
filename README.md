# Keycloak Docker Compose Deployment (with Caddy Reverse Proxy)

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

Configuration Variables:

| Variable Name             | Description                                       | Default Value          |
|---------------------------|---------------------------------------------------|------------------------|
| `KEYCLOAK_APP_HOSTNAME`   | Public domain name for Keycloak                   | `auth.example.com`     |
| `KEYCLOAK_APP_HOST`       | Internal container hostname for Keycloak service  | `keycloak-app`         |
| `KEYCLOAK_ADMIN`          | Admin username for Keycloak                       | `admin`                |
| `KEYCLOAK_ADMIN_PASSWORD` | Admin password for Keycloak                       | *(auto-generated)*     |
| `POSTGRES_DB`             | Name of the PostgreSQL database for Keycloak      | `keycloak`             |
| `POSTGRES_USER`           | PostgreSQL username for Keycloak                  | `keycloak`             |
| `POSTGRES_PASSWORD`       | PostgreSQL password for Keycloak                  | *(auto-generated)*     |

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

### 4. Start the Keycloak Service

```
docker compose up -d
```

This will start Wekan and make your configured domains available.

### 5. Verify Running Containers


```bash
docker ps
```

You should see the `keycloak-app` container running.

### 6. Persistent Data Storage

Keycloak and PostgreSQL use the following bind-mounted volumes for data persistence:

- `./vol/keycloak-postgres/var/lib/postgresql/data` – PostgreSQL database volume
- `./vol/keycloak-app/opt/keycloak/data` – Keycloak runtime data and attachments

---

### Example Directory Structure

```
/docker/keycloak/
├── docker-compose.yml
├── tools/
│   └── init.bash
├── vol/
│   ├── keycloak-app/
│   │   └── data/
│   └── keycloak-db/
├── .env
```

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
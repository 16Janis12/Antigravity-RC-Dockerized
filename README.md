# Antigravity Remote Control (Dockerized)

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Google Antigravity](https://img.shields.io/badge/Google_Antigravity-Remote_Control-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://antigravity.google/docs/remote-control/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Run the headless [Google Antigravity Remote Control](https://antigravity.google/docs/remote-control/) daemon (`agy --remote-control`) inside an isolated, persistent, containerized Docker environment.

---

## 🌟 Overview

The **Antigravity Remote Control** headless daemon lets you host AI agent sessions on any server, homelab, or cloud VM while managing and steering them remotely from any web browser or mobile device via [antigravity.google](https://antigravity.google).

This repository provides a production-ready Docker container and Docker Compose configuration that:
- Runs the Antigravity CLI (`agy`) as a non-root user with `sudo` capabilities.
- Persists Google OAuth credentials and configuration across container restarts and rebuilds.
- Mounts a local workspace folder directly into the container.
- Includes an interactive login flow for first-time Google authentication.

---

## 📁 Repository Structure

```text
.
├── Dockerfile            # Container build specification with CLI & toolchains
├── docker-compose.yml    # Multi-volume Compose configuration
├── entrypoint.sh         # Startup & authentication management script
├── .env.example          # Environment variables template
├── .dockerignore         # Docker context exclusions
├── .gitignore            # Git ignore rules
└── workspace/            # Directory mounted into /workspace in the container
```

---

## 🚀 Quick Start

### Prerequisites
- [Docker Engine](https://docs.docker.com/engine/install/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)
- A Google Account with access to [Google Antigravity](https://antigravity.google)

### 1. Clone the Repository
```bash
git clone git@github.com:16Janis12/Antigravity-RC-Dockerized.git
cd Antigravity-RC-Dockerized
```

### 2. Configure Environment (Optional)
Copy `.env.example` to `.env` and set your preferred instance name:
```bash
cp .env.example .env
```

| Variable | Description | Default |
|---|---|---|
| `AGY_INSTANCE_NAME` | Name displayed for this machine in the Remote Control dashboard | `docker-instance` |
| `AGY_HUB_PORT` | Internal hub port used by the daemon | `4400` |

### 3. Build the Image
```bash
docker compose build
```

### 4. Authenticate (One-Time Setup)
Antigravity requires an initial Google Account login to link the daemon to your account:
```bash
docker compose run --rm antigravity login
```
1. Click or copy the URL printed in the terminal.
2. Sign in with your Google account in your browser and authorize the application.
3. Your authentication tokens are saved in the persistent Docker volume (`gemini_config`).

### 5. Launch the Daemon in the Background
```bash
docker compose up -d
```

### 6. Verify Logs & Connection
```bash
docker compose logs -f
```

Open **[https://antigravity.google](https://antigravity.google)** in any browser — your container will appear in your device list ready to receive tasks!

---

## 🛠️ Management Commands

| Action | Command |
|---|---|
| **View logs** | `docker compose logs -f` |
| **Stop daemon** | `docker compose down` |
| **Restart daemon** | `docker compose restart` |
| **Open shell in container** | `docker compose exec antigravity /bin/bash` |
| **Re-authenticate** | `docker compose run --rm antigravity login` |
| **Update Antigravity CLI** | `docker compose build --no-cache && docker compose up -d` |

---

## 💾 Data Persistence

This setup preserves your session data using named Docker volumes:

| Volume / Path | Destination in Container | Purpose |
|---|---|---|
| `gemini_config` | `/home/antigravity/.gemini` | Google OAuth tokens, credentials, and settings |
| `antigravity_data` | `/home/antigravity/.antigravity` | Daemon runtime logs and cache |
| `./workspace` | `/workspace` | Project files and code accessible by the agent |

---

## 🔒 Security & Best Practices

- **Non-root Execution**: The daemon runs as the `antigravity` user (UID 1000) with passwordless `sudo` access inside the container.
- **Isolated Workspace**: Projects placed inside the `./workspace` directory are mounted cleanly into the container without exposing the rest of your host filesystem.
- **Credential Storage**: Credentials stay isolated within the `gemini_config` Docker volume and are never baked into image layers.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

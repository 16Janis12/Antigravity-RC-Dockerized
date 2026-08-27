# Antigravity Remote Control (Dockerized)

[![Docker CI & Publish](https://github.com/16Janis12/Antigravity-RC-Dockerized/actions/workflows/ci.yml/badge.svg)](https://github.com/16Janis12/Antigravity-RC-Dockerized/actions/workflows/ci.yml)
[![GHCR Image](https://img.shields.io/badge/GHCR-ghcr.io%2F16janis12%2Fantigravity--rc--dockerized-blue?logo=github)](https://github.com/16Janis12/Antigravity-RC-Dockerized/pkgs/container/antigravity-rc-dockerized)
[![Platform Support](https://img.shields.io/badge/Platform-linux%2Famd64%20%7C%20linux%2Farm64-informational?logo=linux)](https://github.com/16Janis12/Antigravity-RC-Dockerized)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Run the headless [Google Antigravity Remote Control](https://antigravity.google/docs/remote-control/) daemon (`agy --remote-control`) inside an isolated, persistent, containerized Docker environment with pre-built multi-architecture images.

---

> [!NOTE]
> ### ⚠️ Disclaimer
> This is an independent, community-driven open-source project and is **not affiliated with, endorsed by, sponsored by, or associated with Google LLC, Alphabet Inc., or any of their subsidiaries**.
> "Google", "Google Antigravity", "Antigravity", and all related logos and brand marks are trademarks of Google LLC.

---

## 🌟 Features

- ⚡ **Zero-Build Quickstart**: Pre-built multi-arch images (`linux/amd64` and `linux/arm64`) published to GitHub Container Registry (`ghcr.io`).
- 🔐 **Persistent Authentication**: Google OAuth tokens and daemon cache persist across restarts via named Docker volumes.
- 👤 **Non-Root Security**: Runs as an `antigravity` user (UID 1000) with passwordless `sudo` privileges.
- 📁 **Workspace Integration**: Mount any local project directory into `/workspace` inside the container.
- 🔄 **Automated CI/CD**: Automatically builds, verifies, and publishes container images on every release.

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml        # Multi-arch build and GHCR publishing workflow
├── Dockerfile            # Container build specification with CLI & toolchains
├── docker-compose.yml    # Compose configuration using pre-built GHCR image
├── entrypoint.sh         # Startup & authentication management script
├── .env.example          # Environment variables template
├── .dockerignore         # Docker context exclusions
├── .gitignore            # Git ignore rules
├── LICENSE               # MIT License
└── workspace/            # Directory mounted into /workspace in the container
```

---

## 🚀 Quick Start (No Build Required)

### Prerequisites
- [Docker Engine](https://docs.docker.com/engine/install/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)
- A Google Account with access to [Google Antigravity](https://antigravity.google)

---

### Method 1: Using Docker Compose (Recommended)

#### 1. Clone the repository
```bash
git clone git@github.com:16Janis12/Antigravity-RC-Dockerized.git
cd Antigravity-RC-Dockerized
```

#### 2. Configure Environment (Optional)
```bash
cp .env.example .env
```

| Variable | Description | Default |
|---|---|---|
| `AGY_INSTANCE_NAME` | Name displayed for this machine in the Remote Control dashboard | `docker-instance` |
| `AGY_HUB_PORT` | Internal hub port used by the daemon | `4400` |

#### 3. One-Time Google Authentication
Docker Compose automatically pulls the pre-built image from GHCR:
```bash
docker compose run --rm antigravity login
```
- Open the printed URL in your browser.
- Sign in with your Google account to authorize the headless daemon.
- Session tokens are saved to the persistent `gemini_config` volume.

#### 4. Launch in Background
```bash
docker compose up -d
```

#### 5. Verify Daemon Status
```bash
docker compose logs -f
```

---

### Method 2: Standalone `docker run`

You can also run the pre-built image directly with Docker CLI:

```bash
# 1. First-time login
docker run -it --rm \
  -v gemini_config:/home/antigravity/.gemini \
  -v antigravity_data:/home/antigravity/.antigravity \
  ghcr.io/16janis12/antigravity-rc-dockerized:latest login

# 2. Start daemon in background
docker run -d \
  --name antigravity-remote-daemon \
  --restart unless-stopped \
  -e AGY_INSTANCE_NAME=my-server \
  -v gemini_config:/home/antigravity/.gemini \
  -v antigravity_data:/home/antigravity/.antigravity \
  -v $(pwd)/workspace:/workspace \
  -p 4400:4400 \
  ghcr.io/16janis12/antigravity-rc-dockerized:latest
```

---

## 🌐 Connecting from Browser

1. Open the **[Antigravity Remote Control Dashboard](https://antigravity.google)** in your browser.
2. Sign in with the same Google Account.
3. Your container will appear under your device list with the name configured in `AGY_INSTANCE_NAME`.

---

## 🛠️ Useful Commands

| Action | Command |
|---|---|
| **View logs** | `docker compose logs -f` |
| **Stop daemon** | `docker compose down` |
| **Restart daemon** | `docker compose restart` |
| **Open container shell** | `docker compose exec antigravity /bin/bash` |
| **Pull latest image** | `docker compose pull` |
| **Re-authenticate** | `docker compose run --rm antigravity login` |
| **Build locally (optional)** | `docker compose build` |

---

## 💾 Data Persistence

| Volume / Path | Destination in Container | Purpose |
|---|---|---|
| `gemini_config` | `/home/antigravity/.gemini` | Google OAuth tokens, credentials, and settings |
| `antigravity_data` | `/home/antigravity/.antigravity` | Daemon runtime logs and cache |
| `./workspace` | `/workspace` | Project files accessible by your agent |

---

## 🔒 Security

- **Non-Root Execution**: Runs as user `antigravity` (UID 1000).
- **No Hardcoded Secrets**: Credentials are stored in Docker named volumes and are never baked into image layers.
- **Isolated Workspace**: Only files inside `./workspace` are mounted into the container.

---

## 📄 License & Legal Notice

Distributed under the [MIT License](LICENSE).

This repository and its maintainers are not affiliated with, endorsed by, sponsored by, or associated with Google LLC or Alphabet Inc.

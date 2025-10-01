#!/usr/bin/env bash
set -e
echo "==> Updating apt and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "==> Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
else
  echo "Docker already installed"
fi

echo "==> Installing docker-compose plugin..."
if ! docker compose version >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y docker-compose-plugin
else
  echo "docker compose already available"
fi

echo "==> Adding current user to docker group (requires logout/login)..."
sudo usermod -aG docker "$USER" || true

echo "==> Done. You may need to log out and back in for group changes to take effect."

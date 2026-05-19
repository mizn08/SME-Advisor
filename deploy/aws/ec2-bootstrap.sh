#!/usr/bin/env bash
# Run on a fresh Ubuntu 22.04 EC2 instance (as ubuntu user with sudo).
set -euo pipefail

sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin git curl
sudo systemctl enable docker
sudo usermod -aG docker "$USER"

if [ ! -d SME-Advisor ]; then
  git clone https://github.com/mizn08/SME-Advisor.git
fi
cd SME-Advisor
cp -n .env.example .env || true
grep -q APP_ENV .env || echo "APP_ENV=production" >> .env

sudo docker compose -f docker-compose.yml -f deploy/aws/docker-compose.prod.yml up -d --build
echo "Health:" && curl -s http://127.0.0.1:8000/health | head -c 500

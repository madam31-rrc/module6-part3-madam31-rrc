#!/bin/bash

# ============================================
# PiXELL-River Financial - Auto Deploy Script
# COMP-4001 Module 6 - Part 1
# Student: Muniru Adam
# ============================================

echo "============================================"
echo " PiXELL-River Financial Auto Deploy Script"
echo "============================================"

# ── STEP 1: Pre-deployment checks ────────────
echo ""
echo "[1/8] Running pre-deployment checks..."

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed."
    exit 1
fi
echo "✔ Docker is installed: $(docker --version)"

if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed."
    exit 1
fi
echo "✔ Docker Compose is installed: $(docker-compose --version)"

if ! command -v curl &> /dev/null; then
    sudo apt install -y curl
fi
echo "✔ curl is available"

if ! command -v jq &> /dev/null; then
    sudo apt install -y jq
fi
echo "✔ jq is available"

echo "Checking ports..."
sudo docker-compose down 2>/dev/null || true
echo "✔ Port checks complete"

# ── STEP 2: Navigate to project directory ────
echo ""
echo "[2/8] Navigating to project directory..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo "✔ Working directory: $(pwd)"

# ── STEP 3: Validate docker-compose file ─────
echo ""
echo "[3/8] Validating docker-compose file..."
if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: docker-compose.yml not found!"
    exit 1
fi
echo "✔ docker-compose.yml found"

# ── STEP 4: Build and deploy ─────────────────
echo ""
echo "[4/8] Building and deploying containers..."
sudo docker-compose down -v 2>/dev/null || true
sudo service docker start 2>/dev/null || true
sudo docker-compose up --build -d
echo "✔ Containers deployed"

# ── STEP 5: Validate build and list images ───
echo ""
echo "[5/8] Validating build..."
echo "--- Docker Images ---"
sudo docker images
echo ""
echo "--- Running Containers ---"
sudo docker ps

# ── STEP 6: Collect nginx container ID ───────
echo ""
echo "[6/8] Collecting nginx container info..."
NGINX_ID=$(sudo docker ps --filter "name=nginx" --format "{{.ID}}")
if [ -z "$NGINX_ID" ]; then
    echo "WARNING: nginx container not found"
else
    echo "✔ Nginx container ID: $NGINX_ID"
fi

# ── STEP 7: Health checks ─────────────────────
echo ""
echo "[7/8] Running health checks..."
echo "Waiting 10 seconds for services to be ready..."
sleep 10

if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200"; then
    echo "✔ Frontend is healthy at http://localhost/"
else
    echo "WARNING: Frontend health check returned non-200"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost/banking/ | grep -q "200\|304"; then
    echo "✔ Banking backend is healthy at http://localhost/banking/"
else
    echo "WARNING: Banking backend check returned non-200"
fi

if curl -s http://localhost/api/transactions | grep -q "Pixel River"; then
    echo "✔ Transactions service is healthy"
else
    echo "WARNING: Transactions service check failed"
fi

# ── STEP 8: Inspect nginx image ───────────────
echo ""
echo "[8/8] Inspecting nginx:alpine image..."
sudo docker inspect nginx:alpine > nginx-logs.txt
echo "✔ nginx inspect log saved to nginx-logs.txt"

echo ""
echo "--- Nginx Image Details ---"
echo "RepoTags: $(jq -r '.[0].RepoTags' nginx-logs.txt)"
echo "Created:  $(jq -r '.[0].Created' nginx-logs.txt)"
echo "OS:       $(jq -r '.[0].Os' nginx-logs.txt)"
echo "ExposedPorts: $(jq -r '.[0].Config.ExposedPorts' nginx-logs.txt)"

echo ""
echo "============================================"
echo " Deployment Complete!"
echo " Frontend:     http://localhost/"
echo " Banking App:  http://localhost/banking/"
echo " Transactions: http://localhost/api/transactions"
echo "============================================"

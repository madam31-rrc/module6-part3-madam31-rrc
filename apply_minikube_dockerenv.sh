#!/bin/bash

# ============================================
# PiXELL-River Financial - Kubernetes Deploy
# COMP-4001 Module 6 - Part 2
# Student: Muniru Adam
# ============================================

echo "============================================"
echo " Kubernetes Auto Deploy Script"
echo "============================================"

# ── STEP 1: Start Minikube ───────────────────
echo ""
echo "[1/6] Starting Minikube..."
minikube start --driver=docker
echo "✔ Minikube started"

# ── STEP 2: Build images in Minikube ─────────
echo ""
echo "[2/6] Building Docker images in Minikube..."
eval $(minikube docker-env)

docker build -t backend:latest ./backend/BankingApp-main
docker build -t transactions:latest ./transactions
docker build -t studentportfolio:latest ./frontend/Studentportfoliotemplate_-main

echo "✔ Images built"

# ── STEP 3: Verify images ────────────────────
echo ""
echo "[3/6] Verifying images inside Minikube..."
docker images | grep -E "backend|transactions|studentportfolio"

# ── STEP 4: Apply manifests ──────────────────
echo ""
echo "[4/6] Applying Kubernetes manifests..."
kubectl apply -f k8s/backend-secret.yaml
kubectl apply -f k8s/mongo-service.yaml
kubectl apply -f k8s/mongo-statefulset.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/transactions-deployment.yaml
kubectl apply -f k8s/transactions-service.yaml
kubectl apply -f k8s/studentportfolio-deployment.yaml
kubectl apply -f k8s/studentportfolio-service.yaml
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml
kubectl apply -f k8s/backend-hpa.yaml
kubectl apply -f k8s/transactions-hpa.yaml
echo "✔ All manifests applied"

# ── STEP 5: Restart deployments ──────────────
echo ""
echo "[5/6] Restarting deployments..."
kubectl rollout restart deployment backend
kubectl rollout restart deployment transactions
kubectl rollout restart deployment studentportfolio
kubectl rollout restart deployment nginx
echo "✔ Deployments restarted"

# ── STEP 6: Show pods ────────────────────────
echo ""
echo "[6/6] Waiting for pods to be ready..."
sleep 30
kubectl get pods
echo ""
kubectl get services

echo ""
echo "============================================"
echo " Deployment Complete!"
echo " Run: minikube service nginx"
echo "============================================"

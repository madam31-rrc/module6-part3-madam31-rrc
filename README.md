# Module 6 Part 3 - PiXELL-River Financial CI/CD Pipeline

## Student: Muniru Adam
## Course: COMP-4001
## GitHub: madam31-rrc

## Overview
This project implements a full CI/CD pipeline for the PiXELL-River 
Financial Banking Application using:
- GitHub Actions for CI (build & push Docker images)
- ArgoCD for CD (GitOps deployment to Kubernetes)
- GitHub Container Registry (GHCR) for image storage

## Services
- Student Portfolio (frontend)
- Banking Backend (Node.js + SQLite)
- Transactions Microservice (JavaScript)
- Nginx Reverse Proxy

## How it works
1. Push code to main branch
2. GitHub Actions builds and pushes Docker images to GHCR
3. GitHub Actions updates image tags in GitOps repo
4. ArgoCD detects changes and deploys to Kubernetes

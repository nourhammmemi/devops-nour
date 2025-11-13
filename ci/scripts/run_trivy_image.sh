#!/bin/bash
set -e

IMAGE_NAME=$1
echo " Scanning Docker image $IMAGE_NAME with Trivy..."

# Scanner l'image pour vulnérabilités CRITICAL
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image \
    --no-progress \
    --severity CRITICAL \
    --exit-code 1 \
    --format json \
    -o trivy-image-report.json \
    "$IMAGE_NAME" || true

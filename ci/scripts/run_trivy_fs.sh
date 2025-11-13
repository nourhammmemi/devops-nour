#!/bin/bash
set -e

echo " Running Trivy filesystem scan (SCA)..."

# Scan via Docker Trivy
docker run --rm -v "$(pwd)":/project aquasec/trivy:latest fs \
    --no-progress \
    --format json \
    -o trivy-fs-report.json /project || true

#  Scan local (optionnel, bloque la build si CRITICAL)
trivy fs --exit-code 1 --severity CRITICAL .

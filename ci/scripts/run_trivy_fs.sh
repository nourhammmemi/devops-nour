#!/bin/bash
set -e
echo " Running Trivy filesystem scan (SCA)..."
docker run --rm -v $(pwd):/project aquasec/trivy:latest fs --no-progress --format json -o trivy-fs-report.json /project || true

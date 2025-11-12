#!/bin/bash
set -e
echo " Running Gitleaks..."
docker run --rm -v $(pwd):/repo zricethezav/gitleaks:latest detect --source=/repo --report-format=json --report-path=gitleaks-report.json || true

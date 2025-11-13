#!/bin/bash
set -e

echo " Running Gitleaks secrets scan..."

# Exécuter Gitleaks sur tout le projet
docker run --rm -v "$(pwd)":/src zricethezav/gitleaks:latest detect \
    --source /src \
    --report-format json \
    --report-path gitleaks-report.json || true

# Bloquer le pipeline si secrets trouvés
if grep -q 'findings' gitleaks-report.json; then
    echo " Secrets detected! Failing the build..."
    exit 1
fi

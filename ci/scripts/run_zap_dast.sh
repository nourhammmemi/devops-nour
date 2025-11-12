#!/bin/bash
set -e
TARGET_URL=$1
echo " Running OWASP ZAP baseline scan on $TARGET_URL..."
docker run --rm -v $(pwd)/zap-report:/zap/wrk/:Z owasp/zap2docker-stable zap-baseline.py -t "$TARGET_URL" -r zap-report.html || true

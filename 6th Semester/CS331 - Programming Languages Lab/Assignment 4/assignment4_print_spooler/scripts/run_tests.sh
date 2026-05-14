#!/usr/bin/env bash
set -euo pipefail
mvn -q clean test
echo "OK: tests passed"

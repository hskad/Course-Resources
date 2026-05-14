#!/usr/bin/env bash
set -euo pipefail
mvn -q test
echo "OK: tests passed"

#!/usr/bin/env bash
set -euo pipefail
echo "[1/2] Packaging (skip tests)..."
mvn -DskipTests package
echo "[2/2] Running SpoolerBench..."
java -cp target/classes edu.iitg.cs.concurrency.printspooler.runtime.SpoolerBench "$@"

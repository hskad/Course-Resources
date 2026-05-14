#!/usr/bin/env bash
set -euo pipefail
mvn -q -DskipTests package
java -cp target/*jar edu.iitg.cs.concurrency.ticketing.runtime.TicketBench "$@"

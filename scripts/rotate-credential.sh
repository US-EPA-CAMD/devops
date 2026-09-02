#!/bin/bash
set -eo pipefail

cf unbind-service $1 camd-pg-db
sleep 5
cf bind-service $1 camd-pg-db
sleep 5
cf restage $1 --strategy rolling
sleep 90

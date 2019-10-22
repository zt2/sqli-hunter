#!/bin/bash
set -e

/root/sqlmap/sqlmapapi.py -s 2>&1 > /dev/null &

exec sqli-hunter --host 0.0.0.0 "$@"

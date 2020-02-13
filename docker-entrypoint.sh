#!/bin/bash
set -e

/root/sqlmap/sqlmapapi.py -s 2>&1 > /dev/null &

cd /root/sqli-hunter/bin && bundler exec ./sqli-hunter.rb --host 0.0.0.0 "$@"

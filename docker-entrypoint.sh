#!/bin/bash
set -e

COMMANDS="adduser debug fg foreground help kill logreopen logtail reopen_transcript run show status stop wait"
START="console start restart"

# Fixing permissions for external /data volumes
mkdir -p /data/blobstorage /data/cache /data/filestorage /data/instance /data/log /data/zeoserver
mkdir -p /plone/instance/src

# Initializing from environment variables
python /docker-initialize.py

if [ -e "custom.cfg" ]; then
  if [ ! -e "bin/develop" ]; then
    buildout -c custom.cfg
    python /docker-initialize.py
  fi
fi

# ZEO Server
if [[ "$1" == "zeo"* ]]; then
  exec bin/$1 fg
fi

# Plone instance start
if [[ $START == *"$1"* ]]; then
  exec bin/instance console
fi

# Plone instance helpers
if [[ $COMMANDS == *"$1"* ]]; then
  exec bin/instance "$@"
fi

# Custom
exec "$@"
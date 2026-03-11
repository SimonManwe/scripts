#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f package.json ]] || ! grep -q '"next"' package.json; then
	echo "not in NextJs project"
	exit 2
fi

if [[ -z "$1" ]]; then
  echo "Usage: $0 <env-name>"
  exit 2
fi
SERVER_ENV_DESIRED_PATH=./env/.env.server-$1
LOCAL_ENV='.env.local'
OLD_ENV_RENAME=".env.local.$(date +%Y%m%d%H%M%S).bak"


if [[ "$1" == "restore" ]]; then

  if [[ $# -ge 2 ]]; then
    BACKUP_FILE="$2"
    if [[ ! -f $BACKUP_FILE ]]; then
      echo "Backup file $BACKUP_FILE not found" >&2
      exit 4
    fi
  else
    BACKUP_FILE=$(ls -t .env.local.*.bak 2>/dev/null | head -n 1)
    if [[ -z $BACKUP_FILE ]]; then
      echo "No backup env file found to restore" >&2
      exit 4
    fi
  fi

  if [[ -f $LOCAL_ENV ]]; then
	  rm $LOCAL_ENV
	  echo "copied env sucessfully removed"
  fi

  cp $BACKUP_FILE $LOCAL_ENV
  echo "Restored env from $BACKUP_FILE"
  rm $BACKUP_FILE
  echo "Removed backup file $BACKUP_FILE"
  exit 0
fi


if [[ -e $SERVER_ENV_DESIRED_PATH ]]; then
	echo "desired env variables found"

	if [[ -f $LOCAL_ENV ]]; then
		echo "local env found preserving values by renaming to $OLD_ENV_RENAME"
		mv $LOCAL_ENV $OLD_ENV_RENAME
	fi

	cp $SERVER_ENV_DESIRED_PATH $LOCAL_ENV
	echo "Env vars switched to: $1"
	exit 0
else
	echo "Server env not found $SERVER_ENV_DESIRED_PATH"
	exit 3
fi



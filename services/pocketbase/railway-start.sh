#!/bin/sh
# Start PocketBase on Railway.
#
# 1. Check the variables. A bad value never stops the deploy (it falls back
#    to a default, or locks the login), so a typo in the deploy form cannot
#    put the service into a restart loop.
# 2. Create or update the superuser from PB_ADMIN_EMAIL / PB_ADMIN_PASSWORD
#    before the port opens, so there is never an unclaimed installer.
# 3. exec "pocketbase serve" on [::]:$PORT (IPv4 and IPv6).
set -eu

DATA_DIR=/pb_data
DEFAULT_EMAIL=admin@example.com
DEFAULT_PORT=8080

log() { printf '%s railway-start: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

PORT_VALUE=${PORT:-$DEFAULT_PORT}
case $PORT_VALUE in
  ''|*[!0-9]*) log "PORT='$PORT_VALUE' is not a number; using $DEFAULT_PORT"; PORT_VALUE=$DEFAULT_PORT ;;
esac
if [ "$PORT_VALUE" -lt 1 ] || [ "$PORT_VALUE" -gt 65535 ]; then
  log "PORT=$PORT_VALUE is out of range; using $DEFAULT_PORT"; PORT_VALUE=$DEFAULT_PORT
fi

# Settings encryption (SMTP and S3 secrets are stored encrypted in the database).
# PocketBase needs exactly 32 characters. Never change the key after the first
# start: the stored settings could not be read any more.
set --
KEY=${PB_ENCRYPTION_KEY:-}
if [ -n "$KEY" ]; then
  if [ "${#KEY}" -eq 32 ]; then
    set -- --encryptionEnv=PB_ENCRYPTION_KEY
  else
    log "WARNING: PB_ENCRYPTION_KEY must be exactly 32 characters (has ${#KEY}); settings are stored unencrypted."
  fi
fi
COMMON="--dir=$DATA_DIR --migrationsDir=/pb/pb_migrations --hooksDir=/pb/pb_hooks --publicDir=/pb/pb_public"

EMAIL=${PB_ADMIN_EMAIL:-}
case $EMAIL in
  ?*@?*.?*) case $EMAIL in *[[:space:]]*) EMAIL= ;; esac ;;
  *) EMAIL= ;;
esac
if [ -z "$EMAIL" ]; then
  log "PB_ADMIN_EMAIL='${PB_ADMIN_EMAIL:-}' is not an email address; using $DEFAULT_EMAIL"
  EMAIL=$DEFAULT_EMAIL
fi

PASS=${PB_ADMIN_PASSWORD:-}
PASS_LEN=${#PASS}
# shellcheck disable=SC2086  # COMMON is a list of flags
if [ "$PASS_LEN" -ge 10 ] && [ "$PASS_LEN" -le 71 ]; then
  if pocketbase superuser upsert "$EMAIL" "$PASS" $COMMON "$@" >/dev/null 2>/tmp/upsert.err; then
    log "Superuser $EMAIL is ready (password from PB_ADMIN_PASSWORD)."
  else
    log "WARNING: could not save superuser $EMAIL: $(head -c 300 /tmp/upsert.err)"
  fi
else
  # Fail closed without failing the deploy: keep an existing superuser as it
  # is; on a fresh volume create one with a random password nobody knows.
  RANDOM_PASS=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 32)
  pocketbase superuser create "$EMAIL" "$RANDOM_PASS" $COMMON "$@" >/dev/null 2>&1 || true
  log "WARNING: PB_ADMIN_PASSWORD must be 10-71 characters (has $PASS_LEN). The superuser password was NOT changed;" \
      "a new superuser gets a random password. Set a valid PB_ADMIN_PASSWORD on the service and redeploy to log in."
fi
rm -f /tmp/upsert.err
unset PB_ADMIN_PASSWORD PASS RANDOM_PASS

log "Starting PocketBase $(pocketbase --version 2>/dev/null | awk '{print $NF}') on port $PORT_VALUE (data in $DATA_DIR)"
# shellcheck disable=SC2086
exec pocketbase serve --http="[::]:$PORT_VALUE" $COMMON "$@"

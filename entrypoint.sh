#!/bin/bash
# Updates the game, logs in to mod.io when mods are enabled (README "Mods (mod.io)"), starts the server.
set -f # LAUNCH_SERVER_ENV is word-split like before, but "?" in map URLs is never glob-expanded
trap 'exit 143' TERM INT

GAME=/home/steam/steamcmd/sandstorm
SERVER=$GAME/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping
MODIO_DIR=$HOME/mod.io
USER_JSON=$MODIO_DIR/254/ModServer/user.json

# steamcmd sometimes fails with "Missing configuration" and works on the next try
for try in 1 2 3; do
  # shellcheck disable=SC2086 # empty APP_UPDATE_EXTRA must vanish
  /home/steam/steamcmd/steamcmd.sh +force_install_dir $GAME/ +login anonymous +app_update 581330 $APP_UPDATE_EXTRA +quit && break
  [ $try = 3 ] && exit 1
  sleep 15
done

# shellcheck disable=SC2206 # split on purpose, same as the old ENTRYPOINT
args=($LAUNCH_SERVER_ENV)
has_arg() {
  local a
  for a in "${args[@]}"; do [[ ${a,,} == "${1,,}" || ${a,,} == "${1,,}="* ]] && return 0; done
  return 1
}
has_token() { [ -n "$(jq -r '.OAuth.token // empty' "$USER_JSON" 2>/dev/null)" ]; }
say() { echo "mod.io: $*" >&2; }

# Sets $code: MODIO_SECURITY_CODE if not used yet, else waits for `modio code` / `modio login`.
get_code() {
  local next=0
  if [ -n "$MODIO_SECURITY_CODE" ] && [ "$MODIO_SECURITY_CODE" != "$(cat "$MODIO_DIR/.used-code" 2>/dev/null)" ]; then
    code=$MODIO_SECURITY_CODE
    return
  fi
  # at most one email per 10 minutes, so a restart loop does not spam mod.io
  if [ -n "$MODIO_EMAIL" ] && [ -z "$(find "$MODIO_DIR/.code-requested" -mmin -10 2>/dev/null)" ]; then
    modio request "$MODIO_EMAIL" && touch "$MODIO_DIR/.code-requested"
  fi
  until [ -s "$MODIO_DIR/security-code" ]; do
    if [ "$SECONDS" -ge "$next" ]; then
      say "waiting for the security code${MODIO_EMAIL:+ emailed to $MODIO_EMAIL}. Send it with:"
      say "  docker exec <container> modio code <CODE>"
      say "no email, or the code expired? get a new one with: docker exec -it <container> modio login"
      next=$((SECONDS + 60))
    fi
    sleep 2
  done
  code=$(cat "$MODIO_DIR/security-code")
  rm -f "$MODIO_DIR/security-code"
}

stop() {
  kill -TERM "$1" 2>/dev/null
  for _ in {1..30}; do kill -0 "$1" 2>/dev/null || break; sleep 1; done
  kill -KILL "$1" 2>/dev/null
  wait "$1" 2>/dev/null
}

# The game redeems the code itself and saves the login to user.json. Boot it once for that, then stop it.
try_code() {
  local pid log=/tmp/modio-login.log
  echo "$code" >"$MODIO_DIR/.used-code"
  rm -f "$USER_JSON"
  say "logging in with the security code, the server starts once and then restarts"
  "$SERVER" "${args[@]}" -SecurityCode="$code" -hostname="$HOSTNAME" -Port="$PORT" -QueryPort="$QUERYPORT" > >(tee "$log") 2>&1 &
  pid=$!
  # shellcheck disable=SC2064 # expand pid now
  trap "stop $pid; exit 143" TERM INT
  for _ in {1..90}; do
    has_token || ! kill -0 $pid 2>/dev/null || grep -q 'Insufficient permission for filesystem operation' "$log" && break
    sleep 2
  done
  stop $pid
  trap 'exit 143' TERM INT
  has_token && say "logged in" && return 0
  if grep -q 'Insufficient permission for filesystem operation' "$log"; then
    rm -f "$MODIO_DIR/.used-code"
    say "the game's mod.io SDK needs io_uring, which Docker's default seccomp profile blocks (Docker 25+)."
    say "recreate the container with --security-opt seccomp=/path/to/seccomp-modio.json (README \"Mods (mod.io)\")."
    say "the code was not used: send it again after that (or the newest one if another email arrives)."
    exit 1
  fi
  say "the code was rejected or expired. Is it a separate mod.io account, not the one you play with?"
  return 1
}

if [ -n "$MODIO_EMAIL" ] && ! has_arg -mods; then args+=(-Mods); fi
if has_arg -mods && ! has_arg -securitycode; then
  mkdir -p "$MODIO_DIR"
  if [ ! -w "$MODIO_DIR" ]; then
    say "$MODIO_DIR is not writable. On the host run: sudo chown -R $(id -u):$(id -g) <folder mounted at $MODIO_DIR>"
    exit 1
  fi
  grep -q " $MODIO_DIR " /proc/self/mountinfo ||
    say "WARNING: $MODIO_DIR is not a volume, the login and the mods are lost when the container is recreated"
  until modio status; do
    get_code
    try_code && break
  done
  modio sync || say "sync failed, starting with the current subscriptions"
  args+=(-SecurityCode=none)
fi

exec "$SERVER" "${args[@]}" -hostname="$HOSTNAME" -Port="$PORT" -QueryPort="$QUERYPORT"

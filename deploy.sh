#!/usr/bin/env bash
# ========================================================================
#  APEX Web — deploy script (Docker path)
#
#  This script is invoked on the VPS by the self-hosted GitHub Actions
#  runner. It pulls the freshly-pushed image from GHCR and recreates the
#  apex-web container. (Watchtower also polls every 5 minutes as a
#  backstop, so this job is the fast path for "live" updates.)
#
#  Required env (set in /etc/default/apex-web or exported at runtime):
#    GHCR_USER    — GitHub username (e.g. rani0707)
#    GHCR_TOKEN   — PAT with read:packages scope
# ========================================================================

set -euo pipefail

log() { echo "[apex-deploy] $*"; }
fail() { echo "[apex-deploy] ✗ $*" >&2; exit 1; }

# ── Resolve paths ──────────────────────────────────────────────────
APP_DIR="${APP_DIR:-/opt/apex-web}"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"

[ -f "$COMPOSE_FILE" ] || fail "docker-compose.yml not found at $COMPOSE_FILE"
command -v docker >/dev/null   || fail "docker not installed (run server-setup.sh)"
docker compose version >/dev/null 2>&1 || fail "'docker compose' plugin missing"

# ── Authenticate to GHCR (idempotent) ─────────────────────────────
GHCR_USER="${GHCR_USER:-${GITHUB_USER:-rani0707}}"
GHCR_TOKEN="${GHCR_TOKEN:-${RUNNER_TOKEN:-}}"
[ -n "$GHCR_TOKEN" ] || fail "GHCR_TOKEN (or RUNNER_TOKEN) is required"

log "Logging into GHCR as $GHCR_USER ..."
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin >/dev/null

# ── Pull new image + recreate container ───────────────────────────
cd "$APP_DIR"
log "Pulling ghcr.io/$GHCR_USER/apex-web:latest ..."
docker compose pull web

log "Recreating apex-web container ..."
docker compose up -d --remove-orphans web

# ── Health check ──────────────────────────────────────────────────
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:20983}"
log "Waiting for $HEALTH_URL ..."
for i in $(seq 1 30); do
  if wget -q --spider "$HEALTH_URL" 2>/dev/null; then
    log "✓ Healthy after ${i}s"
    exit 0
  fi
  sleep 1
done

echo "[apex-deploy] ✗ Health check failed after 30s" >&2
docker compose logs --tail=100 web >&2 || true
exit 1

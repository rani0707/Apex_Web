#!/bin/bash
# ========================================================================
#  APEX Web — Ubuntu 24.04 Initial Server Setup (Docker path)
#  Run this ONCE on a fresh Ubuntu 24.04 server as root (sudo su).
#
#  This installs:
#    • UFW firewall (22, 80, 443, 20983)
#    • Docker Engine + docker compose plugin
#    • A dedicated `apex-runner` user (NOT root) — runs the GitHub Actions runner
#    • The app repository at /opt/apex-web
#    • The apex-web container via docker compose (pulls ghcr.io/<user>/apex-web:latest)
#    • Watchtower — auto-pulls new GHCR images every 5 minutes as backstop
#    • A self-hosted GitHub Actions runner at /opt/actions-runner
#      (this is what makes "git push → live deploy" work without SSH keys)
#
#  Required env vars:
#    RUNNER_TOKEN     — Registration token from
#                       https://github.com/<OWNER>/<REPO>/settings/actions/runners/new
#                       (valid 1 hour; re-run with a fresh token if expired)
#    GHCR_USER        — GitHub username (defaults to GITHUB_USER)
#    GHCR_TOKEN       — PAT with read:packages scope, used for GHCR login
#                       (create at https://github.com/settings/tokens)
#
#  Optional:
#    GITHUB_USER      — defaults to rani0707
#    GITHUB_REPO      — defaults to Apex_Web
#    APP_DIR          — defaults to /opt/apex-web
#    RUNNER_NAME      — defaults to apex-vps-<hostname>
# ========================================================================

set -euo pipefail

GITHUB_USER="${GITHUB_USER:-rani0707}"
GITHUB_REPO="${GITHUB_REPO:-Apex_Web}"
APP_DIR="${APP_DIR:-/opt/apex-web}"
RUNNER_DIR="${RUNNER_DIR:-/opt/actions-runner}"
RUNNER_USER="${RUNNER_USER:-apex-runner}"
RUNNER_NAME="${RUNNER_NAME:-apex-vps-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,apex-prod,linux,x64}"
RUNNER_TOKEN="${RUNNER_TOKEN:-}"
GHCR_USER="${GHCR_USER:-$GITHUB_USER}"
GHCR_TOKEN="${GHCR_TOKEN:-}"

step() { printf "\n\033[1;34m=== %s ===\033[0m\n" "$1"; }
fail() { printf "\n\033[1;31m✗ %s\033[0m\n" "$*" >&2; exit 1; }

# ── 0. Preflight ─────────────────────────────────────────────────────
[ "$(id -u)" -eq 0 ] || fail "Run as root:  sudo su -"

# ── 1. System update ────────────────────────────────────────────────
step "[1/8] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get -y upgrade
echo "Done."

# ── 2. Firewall + utilities ────────────────────────────────────────
step "[2/8] Configuring UFW and utilities..."
apt-get install -y ca-certificates curl gnupg ufw wget git jq sudo
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp  comment "SSH"
ufw allow 20983/tcp comment "APEX Web"
ufw allow 80/tcp  comment "HTTP"
ufw allow 443/tcp comment "HTTPS"
ufw --force enable
ufw status verbose
echo "Done."

# ── 3. Install Docker Engine + compose plugin ──────────────────────
step "[3/8] Installing Docker Engine + compose plugin..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io \
                   docker-buildx-plugin docker-compose-plugin
docker --version
docker compose version
echo "Done."

# ── 4. Create the apex-runner user ──────────────────────────────────
step "[4/8] Creating user '$RUNNER_USER'..."
if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$RUNNER_USER"
fi
# Allow passwordless `docker compose` (runner needs it for deploy.sh).
usermod -aG docker "$RUNNER_USER"
# Also allow this user to interact with docker via sudo as fallback.
cat > /etc/sudoers.d/apex-runner <<EOF
# Managed by server-setup.sh — do not edit by hand.
$RUNNER_USER ALL=(ALL) NOPASSWD: \\
  /usr/bin/docker, \\
  /usr/bin/docker compose
EOF
chmod 440 /etc/sudoers.d/apex-runner
visudo -c -f /etc/sudoers.d/apex-runner >/dev/null
echo "Done."

# ── 5. Clone the repository ────────────────────────────────────────
step "[5/8] Preparing $APP_DIR ..."
if [ -d "$APP_DIR" ]; then
  if [ -d "$APP_DIR/.git" ]; then
    echo "Existing git repo found at $APP_DIR — reusing."
    git -C "$APP_DIR" remote set-url origin \
      "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" 2>/dev/null || true
    git -C "$APP_DIR" fetch --prune
  else
    BACKUP="$APP_DIR.bak.$(date +%s)"
    echo "Existing files at $APP_DIR are not a git repo — moving to $BACKUP ..."
    mv "$APP_DIR" "$BACKUP"
    mkdir -p "$APP_DIR"
    git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$APP_DIR"
  fi
else
  parent="$(dirname "$APP_DIR")"
  mkdir -p "$parent"
  mkdir -p "$APP_DIR"
  git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$APP_DIR"
fi
chown -R "$RUNNER_USER:$RUNNER_USER" "$APP_DIR"
echo "Done."

# ── 6. GHCR login + start containers (web + watchtower) ────────────
step "[6/8] Authenticating to GHCR and starting containers..."
if [ -z "$GHCR_TOKEN" ]; then
  fail "GHCR_TOKEN is required. Create a PAT at https://github.com/settings/tokens with 'read:packages' scope, then re-run with GHCR_TOKEN=<pat>."
fi
# Persist the GHCR login so deploy.sh (run by apex-runner) doesn't have to re-login.
mkdir -p /root/.docker
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin >/dev/null
cp /root/.docker/config.json "$APP_DIR/.docker-config.json"
chown "$RUNNER_USER:$RUNNER_USER" "$APP_DIR/.docker-config.json"
chmod 600 "$APP_DIR/.docker-config.json"

# Pull + start the web service (Watchtower starts too via docker-compose).
cd "$APP_DIR"
docker compose pull web
docker compose up -d --remove-orphans
sleep 3
docker compose ps
echo "Done."

# ── 7. Install self-hosted GitHub Actions runner ───────────────────
step "[7/8] Installing self-hosted GitHub Actions runner..."

if [ -z "$RUNNER_TOKEN" ]; then
  cat <<EOF

  ⚠ RUNNER_TOKEN is required.

  Get one (valid 1 hour) here:
    https://github.com/$GITHUB_USER/$GITHUB_REPO/settings/actions/runners/new

  Then re-run:
    RUNNER_TOKEN=<paste-token> \$0

EOF
  exit 1
fi

if [ ! -x "$RUNNER_DIR/run.sh" ]; then
  mkdir -p "$RUNNER_DIR"
  chown "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"

  # Resolve the latest stable runner version via GitHub API.
  RUNNER_VERSION="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
    | jq -r '.tag_name' | sed 's/^v//')"
  [ -n "$RUNNER_VERSION" ] || fail "Could not determine latest runner version"

  RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

  echo "Downloading actions/runner v${RUNNER_VERSION}..."
  cd "$RUNNER_DIR"
  sudo -u "$RUNNER_USER" curl -fsSL -o runner.tar.gz "$RUNNER_URL"
  sudo -u "$RUNNER_USER" tar xzf runner.tar.gz
  sudo -u "$RUNNER_USER" rm -f runner.tar.gz
fi

# Register the runner (idempotent — uses --replace).
echo "Registering runner '$RUNNER_NAME'..."
cd "$RUNNER_DIR"
sudo -u "$RUNNER_USER" ./config.sh \
  --unattended \
  --replace \
  --url "https://github.com/$GITHUB_USER/$GITHUB_REPO" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work "_work"

# Install + enable systemd service for the runner.
./svc.sh install "$RUNNER_USER"
systemctl enable "actions.runner.${GITHUB_USER}-${GITHUB_REPO}.${RUNNER_NAME}.service"
systemctl start  "actions.runner.${GITHUB_USER}-${GITHUB_REPO}.${RUNNER_NAME}.service"
echo "Done."

# ── 8. Final health check ──────────────────────────────────────────
step "[8/8] Health check..."
sleep 5
HEALTH_URL="http://127.0.0.1:20983"
if wget -q --spider "$HEALTH_URL" 2>/dev/null; then
  echo "✓ apex-web responded at $HEALTH_URL"
else
  echo "✗ apex-web not responding — last 50 log lines:"
  cd "$APP_DIR"
  docker compose logs --tail=50 web || true
  exit 1
fi

EXT_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "<server-ip>")
cat <<EOF

════════════════════════════════════════════════════════════════
  ✓ Site URL      : http://$EXT_IP:20983
  ✓ App dir       : $APP_DIR
  ✓ Runner dir    : $RUNNER_DIR
  ✓ Runner name   : $RUNNER_NAME
  ✓ Runner labels : $RUNNER_LABELS
  ✓ Stack         : Docker (web + Watchtower)

  Auto-deploy is now wired up (DOCKER path).

  • Push to main on github.com/$GITHUB_USER/$GITHUB_REPO
  • The Build & Verify job runs on GitHub-hosted runners
  • The Push Image job pushes ghcr.io/$GHCR_USER/apex-web:latest
  • The Deploy job (self-hosted) runs ./deploy.sh on THIS server:
      docker compose pull && docker compose up -d
  • Watchtower also polls GHCR every 5 minutes as a backstop.

  Logs:
    cd $APP_DIR && docker compose logs -f web
    cd $APP_DIR && docker compose logs -f watchtower
    sudo journalctl -u actions.runner.* -f

  Manual redeploy:
    cd $APP_DIR && sudo -u $RUNNER_USER ./deploy.sh

════════════════════════════════════════════════════════════════
EOF
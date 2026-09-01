#!/bin/bash
# ========================================================================
#  APEX Web — Ubuntu 24.04 Initial Server Setup
#  Run this ONCE on a fresh Ubuntu 24.04 server as root (sudo su).
#
#  This installs:
#    • Node.js 20 + system deps
#    • UFW firewall (22, 80, 443, 20983)
#    • A dedicated `apex-runner` user (NOT root)
#    • The app repository at /opt/apex-web
#    • apex-web.service (systemd)
#    • A self-hosted GitHub Actions runner at /opt/actions-runner
#      (this is what makes "git push → live deploy" work without SSH keys)
#
#  Required env var (export before running, or pass inline):
#    RUNNER_TOKEN     — Registration token from
#                       https://github.com/<OWNER>/<REPO>/settings/actions/runners/new
#                       (valid 1 hour; re-run this script with a fresh token if it expires)
#
#  Optional:
#    GITHUB_USER      — defaults to YOUR_GITHUB_USERNAME
#    GITHUB_REPO      — defaults to Apex_Web
#    APP_DIR          — defaults to /opt/apex-web
#    RUNNER_NAME      — defaults to apex-vps-<hostname>
# ========================================================================

set -euo pipefail

GITHUB_USER="${GITHUB_USER:-YOUR_GITHUB_USERNAME}"
GITHUB_REPO="${GITHUB_REPO:-Apex_Web}"
APP_DIR="${APP_DIR:-/opt/apex-web}"
RUNNER_DIR="${RUNNER_DIR:-/opt/actions-runner}"
RUNNER_USER="${RUNNER_USER:-apex-runner}"
RUNNER_NAME="${RUNNER_NAME:-apex-vps-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,apex-prod,linux,x64}"
RUNNER_TOKEN="${RUNNER_TOKEN:-}"

step() { printf "\n\033[1;34m=== %s ===\033[0m\n" "$1"; }
fail() { printf "\n\033[1;31m✗ %s\033[0m\n" "$*" >&2; exit 1; }

# ── 0. Preflight ─────────────────────────────────────────────────────
[ "$(id -u)" -eq 0 ] || fail "Run as root:  sudo su -"

# ── 1. System update ────────────────────────────────────────────────
step "[1/8] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get -y upgrade
echo "Done."

# ── 2. Install Node.js 20 + utilities ───────────────────────────────
step "[2/8] Installing Node.js 20 + utilities..."
apt-get install -y ca-certificates curl gnupg ufw wget git jq sudo
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi
node -v
npm -v
echo "Done."

# ── 3. Firewall ─────────────────────────────────────────────────────
step "[3/8] Configuring UFW..."
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

# ── 4. Create the apex-runner user ──────────────────────────────────
step "[4/8] Creating user '$RUNNER_USER'..."
if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$RUNNER_USER"
fi
# Allow this user to restart the apex-web service without a password.
# This is the ONLY sudo capability the runner gets.
cat > /etc/sudoers.d/apex-runner <<EOF
# Managed by server-setup.sh — do not edit by hand.
$RUNNER_USER ALL=(ALL) NOPASSWD: \\
  /usr/bin/systemctl restart apex-web, \\
  /usr/bin/systemctl status apex-web, \\
  /usr/bin/systemctl is-active apex-web, \\
  /usr/bin/journalctl -u apex-web *
EOF
chmod 440 /etc/sudoers.d/apex-runner
visudo -c -f /etc/sudoers.d/apex-runner >/dev/null
echo "Done."

# ── 5. Clone the repository ────────────────────────────────────────
step "[5/8] Preparing $APP_DIR ..."
if [[ "$APP_DIR" == /home/* || "$APP_DIR" == /root/* ]]; then
  if [[ "$FORCE" != "1" ]]; then
    cat <<EOF
⚠️  NOTE: APP_DIR=$APP_DIR is under a user home directory.
   All files will be owned by 'apex-runner'. Your normal account will
   no longer have write access to this directory after installation.
EOF
    read -r -p "Continue? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  else
    echo "FORCE=1 set — skipping confirmation."
  fi
fi

if [ -d "$APP_DIR" ]; then
  if [ -d "$APP_DIR/.git" ]; then
    echo "Existing git repo found at $APP_DIR — reusing."
    # Fix remote URL and fetch latest (even if owned by another user, chown below fixes that).
    sudo -u "$RUNNER_USER" git -C "$APP_DIR" remote set-url origin \
      "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" 2>/dev/null \
      || git -C "$APP_DIR" remote set-url origin \
         "https://github.com/$GITHUB_USER/$GITHUB_REPO.git"
    sudo -u "$RUNNER_USER" git -C "$APP_DIR" fetch --prune 2>/dev/null \
      || git -C "$APP_DIR" fetch --prune
  else
    echo "ERROR: $APP_DIR exists but is not a git repo." >&2
    echo "       Remove it or set APP_DIR to an empty path before re-running." >&2
    exit 1
  fi
else
  # Create the directory tree as root, hand it to apex-runner, then clone.
  parent="$(dirname "$APP_DIR")"
  mkdir -p "$parent"
  mkdir -p "$APP_DIR"
  chown "$RUNNER_USER:$RUNNER_USER" "$APP_DIR"
  sudo -u "$RUNNER_USER" git clone \
    "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$APP_DIR"
fi

# Ensure apex-runner owns the tree (handles dirs owned by root or rani0707).
chown -R "$RUNNER_USER:$RUNNER_USER" "$APP_DIR"
echo "Done."

# ── 6. Install apex-web systemd service ─────────────────────────────
step "[6/8] Installing systemd unit..."
mkdir -p /var/log/apex-web
chown "$RUNNER_USER:$RUNNER_USER" /var/log/apex-web
install -m 0644 "$APP_DIR/deploy/apex-web.service" /etc/systemd/system/apex-web.service
# Patch the default path baked into the unit file so it matches APP_DIR.
sed -i "s|/opt/apex-web|$APP_DIR|g" /etc/systemd/system/apex-web.service
# Allow the service to write into the actual app dir (overrides ProtectSystem=strict).
sed -i "s|ReadWritePaths=/opt/apex-web|ReadWritePaths=$APP_DIR|g" /etc/systemd/system/apex-web.service
# When APP_DIR lives under /home or /root, ProtectHome=true would block it.
if [[ "$APP_DIR" == /home/* || "$APP_DIR" == /root/* ]]; then
  sed -i 's|^ProtectHome=true|# ProtectHome=true  (APP_DIR under /home — disabled by server-setup.sh)|' \
    /etc/systemd/system/apex-web.service
  echo "APP_DIR is under /home — ProtectHome disabled for apex-web.service."
fi
systemctl daemon-reload
systemctl enable apex-web.service
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

# ── 8. Build & start apex-web ──────────────────────────────────────
step "[8/8] Building & starting apex-web..."
cd "$APP_DIR"
export NEXT_TELEMETRY_DISABLED=1
sudo -u "$RUNNER_USER" npm ci --ignore-scripts
sudo -u "$RUNNER_USER" npm run build
systemctl restart apex-web
sleep 3
systemctl is-active --quiet apex-web \
  && echo "✓ apex-web is active." \
  || { echo "apex-web failed to start:"; journalctl -u apex-web -n 100 --no-pager; exit 1; }

# ── Done ────────────────────────────────────────────────────────────
EXT_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "<server-ip>")
cat <<EOF

════════════════════════════════════════════════════════════════
  ✓ Site URL      : http://$EXT_IP:20983
  ✓ App dir       : $APP_DIR
  ✓ Runner dir    : $RUNNER_DIR
  ✓ Runner name   : $RUNNER_NAME
  ✓ Runner labels : $RUNNER_LABELS

  Auto-deploy is now wired up.

  • Push to main on github.com/$GITHUB_USER/$GITHUB_REPO
  • The Build & Verify job runs on GitHub-hosted runners
  • The Deploy job runs on THIS server (via the self-hosted runner)
  • deploy.sh rebuilds and restarts apex-web
  • No SSH keys, no secrets in GitHub Actions.

  Logs:
    sudo journalctl -u apex-web -f
    sudo journalctl -u actions.runner.* -f

  Manual redeploy:
    cd $APP_DIR && sudo -u $RUNNER_USER ./deploy.sh

════════════════════════════════════════════════════════════════
EOF
#!/bin/bash

######################################
# Chrony GPS Monitor - Install/Update Script
######################################
#
# This script installs or updates the GPS monitoring system
# Usage: sudo ./install.sh
#

set -e  # Exit on error

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)" 
   exit 1
fi

echo "📦 Installing Chrony GPS Monitor..."

######################################
# CONFIGURATION
######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_SCRIPT="$SCRIPT_DIR/check_gps_status.sh"
INSTALL_PATH="/usr/local/bin/check_gps_status.sh"
SERVICE_NAME="chrony-gps-monitor"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TIMER_FILE="/etc/systemd/system/${SERVICE_NAME}.timer"

######################################
# INSTALL MONITORING SCRIPT
######################################

if [[ ! -f "$MONITOR_SCRIPT" ]]; then
    echo "❌ Error: check_gps_status.sh not found in $SCRIPT_DIR"
    exit 1
fi

echo "📋 Installing monitoring script to $INSTALL_PATH..."
cp "$MONITOR_SCRIPT" "$INSTALL_PATH"

# Fix line endings (convert CRLF to LF if needed)
# This prevents "No such file or directory" errors with the shebang
if command -v dos2unix &> /dev/null; then
    dos2unix "$INSTALL_PATH" 2>/dev/null || true
else
    # Fallback: use sed to remove carriage returns
    sed -i 's/\r$//' "$INSTALL_PATH"
fi

chmod 755 "$INSTALL_PATH"
echo "✅ Script installed"

######################################
# CREATE SYSTEMD SERVICE
######################################

echo "📋 Creating systemd service file..."
cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Chrony GPS Monitor
Documentation=https://github.com/yourusername/chrony-monitor
After=network-online.target chronyd.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check_gps_status.sh

# Runtime directory for state file
RuntimeDirectory=chrony-gps-monitor
RuntimeDirectoryMode=0755

# Security hardening
DynamicUser=yes
ProtectSystem=strict
ProtectHome=yes
NoNewPrivileges=yes
PrivateTmp=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
RestrictRealtime=yes
RestrictNamespaces=yes
RestrictSUIDSGID=yes
LockPersonality=yes
MemoryDenyWriteExecute=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources
SystemCallErrorNumber=EPERM

# Capabilities
CapabilityBoundingSet=
AmbientCapabilities=

# Process limits
TasksMax=10
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$SERVICE_FILE"
echo "✅ Service file created"

######################################
# CREATE SYSTEMD TIMER
######################################

echo "📋 Creating systemd timer file..."
cat > "$TIMER_FILE" << 'EOF'
[Unit]
Description=Chrony GPS Monitor Timer
Documentation=https://github.com/yourusername/chrony-monitor

[Timer]
# Run every minute
OnBootSec=30s
OnUnitActiveSec=1min
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF

chmod 644 "$TIMER_FILE"
echo "✅ Timer file created"

######################################
# RELOAD AND ENABLE
######################################

echo "📋 Reloading systemd daemon..."
systemctl daemon-reload

echo "📋 Enabling and starting timer..."
systemctl enable "${SERVICE_NAME}.timer"
systemctl restart "${SERVICE_NAME}.timer"

######################################
# STATUS CHECK
######################################

echo ""
echo "✅ Installation complete!"
echo ""
echo "Status:"
systemctl status "${SERVICE_NAME}.timer" --no-pager || true
echo ""
echo "📊 To view logs:"
echo "   journalctl -u ${SERVICE_NAME}.service -f"
echo ""
echo "📊 To check timer status:"
echo "   systemctl status ${SERVICE_NAME}.timer"
echo ""
echo "📊 To manually run the check:"
echo "   systemctl start ${SERVICE_NAME}.service"
echo ""
echo "⚙️  To modify settings, edit: $INSTALL_PATH"
echo "   Then run: sudo ./install.sh  (to update)"
echo ""

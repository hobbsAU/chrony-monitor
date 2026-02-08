#!/bin/bash

######################################
# Chrony GPS Monitor - Uninstall Script
######################################
#
# This script removes the GPS monitoring system
# Usage: sudo ./uninstall.sh
#

set -e  # Exit on error

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)" 
   exit 1
fi

echo "🗑️  Uninstalling Chrony GPS Monitor..."

######################################
# CONFIGURATION
######################################

INSTALL_PATH="/usr/local/bin/check_gps_status.sh"
SERVICE_NAME="chrony-gps-monitor"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TIMER_FILE="/etc/systemd/system/${SERVICE_NAME}.timer"
STATUS_FILE="/var/tmp/gps_primary_status"

######################################
# STOP AND DISABLE SERVICE
######################################

echo "📋 Stopping and disabling service..."
systemctl stop "${SERVICE_NAME}.timer" 2>/dev/null || true
systemctl stop "${SERVICE_NAME}.service" 2>/dev/null || true
systemctl disable "${SERVICE_NAME}.timer" 2>/dev/null || true

######################################
# REMOVE FILES
######################################

echo "📋 Removing systemd files..."
rm -f "$SERVICE_FILE"
rm -f "$TIMER_FILE"

echo "📋 Removing monitoring script..."
rm -f "$INSTALL_PATH"

echo "📋 Removing status file..."
rm -f "$STATUS_FILE"

######################################
# RELOAD SYSTEMD
######################################

echo "📋 Reloading systemd daemon..."
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

######################################
# DONE
######################################

echo ""
echo "✅ Uninstallation complete!"
echo ""
echo "The Chrony GPS Monitor has been removed from your system."
echo ""

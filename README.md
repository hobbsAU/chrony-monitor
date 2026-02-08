# Chrony GPS Monitor
Easy script that monitors the GPS Chrony NTP source and sends notifications via Gotify and/or Discord on status changes.

<img width="1144" height="555" alt="afbeelding" src="https://github.com/user-attachments/assets/66e38159-861a-47b4-a224-100502599d4d" />

### **Script Summary**

1.  **Checks the NTP GPS source:**
    
    - Uses chronyc sources to find the GPS/NMEA source by name (e.g., "NMEA" or "PPS") and read its primary marker and reach value.
        
2.  **Determines GPS status:**
    
    -  Status is OK if the GPS source is the primary time source (#*) and its reach value is greater than 0 (has signal).

    -  Status is FAIL if it is not the primary source or the reach value is 0 (lost signal).
        
3.  **Compares with previous status:**
    
    -  Reads the last known status from a temporary file and only proceeds if the status has changed.
        
4.  **Sends notifications on status change:**
    -  If GPS fails: sends a **high-priority alert** to configured services.
        
    -  If GPS is restored: sends a **restoration notice** to configured services.

    -  Supports **Gotify** and/or **Discord** notifications (configure either or both).
        
5.  **Stores the current status:**
    
    - Saves the current status to a file for the next check.

---

## 🚀 Quick Installation (Recommended)

### Prerequisites
- Chrony NTP daemon running with GPS/NMEA/PPS source
- Root access (sudo)

### Automated Install

1. **Clone or download this repository:**
```bash
git clone https://github.com/yourusername/chrony-monitor.git
cd chrony-monitor
```

2. **Configure your notification settings:**
```bash
nano check_gps_status.sh
```
Edit the configuration section at the top:
- Set `GOTIFY_URL` with your Gotify server URL and token (or leave empty to disable)
- Set `DISCORD_WEBHOOK_URL` with your Discord webhook URL (or leave empty to disable)
- Adjust `GPS_NAME` if your source is named differently (default: "PPS")

3. **Run the installer:**
```bash
sudo ./install.sh
```

The installer will:
- Install the script to `/usr/local/bin/`
- Create a systemd service with security hardening
- Create a systemd timer to run checks every minute
- Enable and start the monitoring service

4. **Verify installation:**
```bash
systemctl status chrony-gps-monitor.timer
journalctl -u chrony-gps-monitor.service -f
```

That's it! 🎉 Your GPS monitoring is now active.

---

## 📝 Manual Installation

If you prefer to install manually or need to customize the setup:

## By Anoniemerd

### 1️⃣ Create the Script

Create the monitoring script:

```bash
sudo nano /usr/local/bin/check_gps_status.sh
```
Copy and paste the script content from `check_gps_status.sh` in this repository, or copy the code below and customize the configuration section:

```bash
#!/bin/bash

######################################
# CONFIGURATION (to customize)
######################################

# Gotify server URL + API token
# REPLACE with your own server address and token
# Leave empty to disable Gotify notifications
GOTIFY_URL="https://your-gotify-server.com/message?token=YOUR_TOKEN"

# Discord webhook URL
# REPLACE with your Discord webhook URL
# Leave empty to disable Discord notifications
DISCORD_WEBHOOK_URL=""

# Name of the GPS/NMEA source as it appears in 'chronyc sources'
# Change this if your source has a different name than "NMEA"
GPS_NAME="PPS"  # Example: "PPS", "NMEA", or whatever your GPS source is called in chronyc

# Location of the temporary status file
# Usually, you don't need to change this
STATUS_FILE="/var/tmp/gps_primary_status"

# ... (rest of script - see check_gps_status.sh for full code)
```

### 2️⃣ Make the Script Executable

```bash
sudo chmod +x /usr/local/bin/check_gps_status.sh
```

### 3️⃣ Schedule the Script
Set up a cron job to run the script every minute:
```bash
sudo crontab -e
```
Add the line:
```bash
* * * * * /usr/local/bin/check_gps_status.sh
```

### 4️⃣ Finished 🎉
Your GPS monitoring script is now running in the background. You'll receive alerts via your configured notification service(s) (Gotify and/or Discord) whenever the GPS/NMEA source stops or resumes being the primary NTP source.

---

## 🔧 Configuration

### Notification Services

**Gotify:**
- Set `GOTIFY_URL` to your Gotify server URL with token: `https://gotify.example.com/message?token=YOUR_TOKEN`
- Leave empty to disable Gotify notifications

**Discord:**
- Create a webhook in your Discord server (Server Settings → Integrations → Webhooks)
- Set `DISCORD_WEBHOOK_URL` to your webhook URL
- Leave empty to disable Discord notifications

You can enable one, both, or neither notification service.

### GPS Source Name
- Check your chrony sources: `chronyc sources`
- Look for your GPS/NMEA/PPS source name in the second column
- Update `GPS_NAME` in the script if it's not "PPS"

---

## 📊 Monitoring & Logs

### View service status:
```bash
systemctl status chrony-gps-monitor.timer
systemctl status chrony-gps-monitor.service
```

### View logs:
```bash
# Follow logs in real-time
journalctl -u chrony-gps-monitor.service -f

# View recent logs
journalctl -u chrony-gps-monitor.service -n 50
```

### Manually trigger a check:
```bash
sudo systemctl start chrony-gps-monitor.service
```

---

## 🔒 Security Features

The automated installation sets up the systemd service with extensive security hardening:
- **DynamicUser**: Runs with ephemeral user (no persistent system user needed)
- **Filesystem protection**: Read-only root, protected home, isolated /tmp
- **Kernel protection**: Protected tunables, modules, and logs
- **Network restriction**: Limited to IPv4/IPv6/Unix sockets only
- **System call filtering**: Restricted to safe system calls
- **No escalation**: Cannot gain privileges or create SUID binaries
- **Resource limits**: Low priority, limited tasks, idle I/O scheduling

---

## 🛠️ Updating

To update the monitoring script:
1. Edit `check_gps_status.sh` with your changes
2. Run `sudo ./install.sh` again

The installer will update the script and restart the service.

---

## 🗑️ Uninstalling

To completely remove the monitoring system:
```bash
sudo ./uninstall.sh
```

This will:
- Stop and disable the systemd service and timer
- Remove all installed files
- Clean up the status file

---

## By Anoniemerd


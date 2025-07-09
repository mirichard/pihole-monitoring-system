# Pi-hole Monitoring System Documentation

## Overview

This Pi-hole monitoring system provides comprehensive monitoring and alerting for your Pi-hole DNS server, including system health metrics, service status, and intelligent alert management with maintenance mode support.

## Components

### 1. Main Alert Script (`/usr/local/bin/pihole-alert.sh`)
The primary monitoring script that checks system health and sends email alerts when issues are detected.

### 2. Maintenance Mode Script (`/usr/local/bin/maintenance-mode`)
A utility script to control maintenance mode, which suppresses service failure alerts during planned maintenance.

### 3. Log File (`/var/log/pihole-monitor.log`)
Central log file that tracks all monitoring activities, alerts, and maintenance mode changes.

## Features

### System Monitoring
- **Temperature**: Warns at >60°C, Critical at >65°C
- **CPU Load**: Warns at >2.0, Critical at >4.0
- **Memory Usage**: Warns at >80%, Critical at >90%
- **Disk Usage**: Warns at >80%, Critical at >90%
- **Voltage**: Warns if <1.2V (under-voltage detection)

### Service Monitoring
- **Pi-hole FTL**: Monitors the core Pi-hole service
- **Unbound DNS**: Monitors the DNS resolver service
- **DNS Performance**: Tracks query response times
- **DNS Resolution**: Verifies DNS functionality
- **Network Connectivity**: Tests external connectivity

### Pi-hole Specific Metrics
- **Blocked Domains**: Warns if <100,000 domains
- **Blocking Rate**: Warns if <5% of queries blocked
- **Daily Statistics**: Tracks queries and blocks

### Intelligent Alerting
- **Retry Logic**: Services are checked up to 3 times before alerting
- **Maintenance Mode**: Suppresses service alerts during planned maintenance
- **Detailed Logging**: All actions are logged for audit trail

## Configuration

### Alert Script Configuration
Edit `/usr/local/bin/pihole-alert.sh` to modify:

```bash
RECHECK_DELAY=30      # Seconds between retry attempts
MAX_RETRIES=3         # Maximum retry attempts
MAINTENANCE_FILE="/tmp/maintenance_mode"  # Maintenance mode flag file
```

### Email Configuration
The script sends alerts to: `michaelrichard4@gmail.com`

To change the email address, modify the mail command in the script:
```bash
mail -s "..." your-email@example.com
```

## Usage

### Running the Alert Script
```bash
# Run manually (requires sudo)
sudo /usr/local/bin/pihole-alert.sh

# Typical output when no issues:
No issues detected - system running normally

# Typical output when issues found:
Alert sent - Issues detected and reported
```

### Maintenance Mode Management

#### Enable Maintenance Mode
```bash
# Enable for default 60 minutes
maintenance-mode on

# Enable for specific duration
maintenance-mode on -t 30

# Enable with reason
maintenance-mode on -t 120 -r "System updates"
```

#### Check Maintenance Status
```bash
maintenance-mode status

# Example output when active:
🔧 Maintenance mode is ACTIVE

Details:
  Start time: 2025-07-09 08:52:05
  End time: 2025-07-09 09:52:05
  Duration: 60 minutes
  Reason: System updates
  Time remaining: 45 minutes
```

#### Disable Maintenance Mode
```bash
maintenance-mode off
```

#### Get Help
```bash
maintenance-mode help
```

## Maintenance Mode Behavior

### During Maintenance Mode:
- ✅ **System alerts still fire** (temperature, CPU, memory, disk, voltage)
- ❌ **Service failure alerts are suppressed** (Pi-hole FTL, Unbound DNS)
- 🏷️ **All alerts are tagged with [MAINTENANCE MODE]**
- 📧 **Email subject includes [MAINTENANCE]**
- ⏰ **Automatically expires after specified time**

### What Gets Suppressed:
- Pi-hole FTL service down alerts
- Unbound DNS service down alerts
- DNS resolution failure alerts (marked as maintenance)

### What Still Alerts:
- High temperature
- High CPU load
- High memory usage
- High disk usage
- Low voltage warnings
- Network connectivity issues
- Performance degradation

## Automation

### Cron Job Setup
To run the monitoring script automatically, add to crontab:

```bash
# Edit crontab
sudo crontab -e

# Add this line to run every 5 minutes
*/5 * * * * /usr/local/bin/pihole-alert.sh

# Or run every 15 minutes
*/15 * * * * /usr/local/bin/pihole-alert.sh
```

## Log Management

### View Recent Log Entries
```bash
# View last 10 entries
sudo tail -10 /var/log/pihole-monitor.log

# View last 50 entries
sudo tail -50 /var/log/pihole-monitor.log

# Follow log in real-time
sudo tail -f /var/log/pihole-monitor.log
```

### Log Rotation
Consider setting up log rotation to prevent the log file from growing too large:

```bash
# Create logrotate configuration
sudo tee /etc/logrotate.d/pihole-monitor << 'LOGROTATE'
/var/log/pihole-monitor.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
LOGROTATE
```

## Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Fix log file permissions
sudo chown root:root /var/log/pihole-monitor.log
sudo chmod 644 /var/log/pihole-monitor.log

# Fix script permissions
sudo chmod +x /usr/local/bin/pihole-alert.sh
sudo chmod +x /usr/local/bin/maintenance-mode
```

#### Email Not Sending
1. Verify mail system is configured
2. Check `/var/log/mail.log` for mail errors
3. Test with: `echo "test" | mail -s "test" your-email@example.com`

#### Service Checks Failing
```bash
# Test Pi-hole FTL
pidof pihole-FTL

# Test Unbound
systemctl is-active unbound

# Test DNS resolution
dig @127.0.0.1 -p 5335 google.com
```

### Debug Mode
To run the script with more verbose output, add debug statements:

```bash
# Add to script for debugging
set -x  # Enable debug mode
set +x  # Disable debug mode
```

## Sample Alert Email

```
Subject: Pi-hole Alert: Issues Detected on pi-server

Pi-hole Alert Report - 2025-07-09 08:52:19

ALERTS:
WARNING: High memory usage at 85%
CRITICAL: Pi-hole FTL service is not running (verified after retries)

System Status Report:
Temperature: 45.2°C
CPU Load: 1.2
CPU Frequency: 1500MHz
Voltage: 1.35V
Memory Usage: 85%
Disk Usage: 45%

Pi-hole Statistics:
Blocked Domains: 150000
Queries Today: 1250
Ads Blocked Today: 125
Blocking Rate: 10.00%

DNS Performance:
Response Time: 25ms

Monitoring Configuration:
Recheck Delay: 30s
Max Retries: 3
Maintenance Mode: inactive
```

## Best Practices

### 1. Regular Monitoring
- Run the script every 5-15 minutes via cron
- Monitor the log file for patterns
- Review alerts promptly

### 2. Maintenance Planning
- Enable maintenance mode before planned work
- Use descriptive reasons for maintenance
- Verify maintenance mode is disabled after work

### 3. Alert Tuning
- Adjust thresholds based on your system's normal behavior
- Monitor false positives and adjust retry logic
- Customize email content as needed

### 4. Log Management
- Implement log rotation
- Monitor log file size
- Archive old logs if needed

## Version History

- **v2.0**: Added retry logic and maintenance mode support
- **v1.0**: Initial monitoring script

## Contact

For issues or questions, check the log file first, then review this documentation.

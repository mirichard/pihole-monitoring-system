# Pi-hole Monitoring Quick Reference

## Daily Commands

### Run Alert Check
```bash
sudo /usr/local/bin/pihole-alert.sh
```

### Maintenance Mode
```bash
# Enable (60 min default)
maintenance-mode on

# Enable with custom time and reason
maintenance-mode on -t 30 -r "System updates"

# Check status
maintenance-mode status

# Disable
maintenance-mode off
```

### Check Logs
```bash
# Recent entries
sudo tail -10 /var/log/pihole-monitor.log

# Follow live
sudo tail -f /var/log/pihole-monitor.log
```

## Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Temperature | >60°C | >65°C |
| CPU Load | >2.0 | >4.0 |
| Memory | >80% | >90% |
| Disk | >80% | >90% |
| Voltage | <1.2V | - |
| DNS Response | >1000ms | - |
| Blocked Domains | <100,000 | - |
| Blocking Rate | <5% | - |

## Files

- **Main Script**: `/usr/local/bin/pihole-alert.sh`
- **Maintenance Tool**: `/usr/local/bin/maintenance-mode`
- **Log File**: `/var/log/pihole-monitor.log`
- **Maintenance Flag**: `/tmp/maintenance_mode`

## Cron Setup
```bash
sudo crontab -e
# Add: */5 * * * * /usr/local/bin/pihole-alert.sh
```

## Emergency Commands
```bash
# Check services manually
pidof pihole-FTL
systemctl is-active unbound

# Test DNS
dig @127.0.0.1 -p 5335 google.com

# Test network
ping -c 1 8.8.8.8
```

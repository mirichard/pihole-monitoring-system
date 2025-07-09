# Issue Resolved: Incorrect Pi-hole Statistics

## 🐛 Problem Description

The Pi-hole monitoring script was reporting incorrect statistics:
- **Blocked Domains**: 0 (should be ∼1.4 million)
- **Queries Today**: 0 (should be thousands)
- **Ads Blocked Today**: 0 (should be hundreds)

**Alert Message:**
```
Pi-hole Alert Report - 2025-07-09 09:30:01

ALERTS:
WARNING: Low number of blocked domains: 0

System Status Report:
Temperature: 42.4°C
CPU Load: 0.08
CPU Frequency: 1000MHz
Voltage: 1.2625V
Memory Usage: 37%
Disk Usage: 2%

Pi-hole Statistics:
Blocked Domains: 0
Queries Today: 0
Ads Blocked Today: 0
Blocking Rate: 0%

DNS Performance:
Response Time: 45ms
```

## 🔍 Root Cause Analysis

### 1. **Deprecated API Usage**
- Script was using `pihole -c -j` (chronometer) which has been deprecated.
- Command now returns: `Chronometer is gone, use PADD (https://github.com/pi-hole/PADD)`.

### 2. **Incorrect Database Path**
- Script was looking for FTL database at: `/var/log/pihole/pihole-FTL.db`.
- Actual location: `/etc/pihole/pihole-FTL.db`.

### 3. **Wrong Table for Blocked Domains**
- Script was checking `domainlist` table (returned 0).
- Should check `gravity` table (contains 1,418,808 domains).

### 4. **Logging Disabled**
- Pi-hole query logging was disabled.
- No queries were being recorded in the database.

## 🛠️ Solution Applied

### Database Query Updates
**Before:**
```bash
blocked_domains=$(pihole -c -j | grep "domains_being_blocked" | cut -d":" -f2 | tr -d ", ")
ads_blocked_today=$(pihole -c -j | grep "ads_blocked_today" | cut -d":" -f2 | tr -d ", ")
dns_queries_today=$(pihole -c -j | grep "dns_queries_today" | cut -d":" -f2 | tr -d ", ")
```

**After:**
```bash
# Get Pi-hole stats using database queries (new method)
blocked_domains=$(sudo sqlite3 /etc/pihole/gravity.db "SELECT COUNT(*) FROM gravity;" 2>/dev/null || echo "0")
ads_blocked_today=$(sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE (status = 1 OR status = 4 OR status = 5 OR status = 6 OR status = 7 OR status = 8 OR status = 9 OR status = 10 OR status = 11) AND timestamp >= strftime('%s', datetime('now', 'start of day'));" 2>/dev/null || echo "0")
dns_queries_today=$(sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE timestamp >= strftime('%s', datetime('now', 'start of day'));" 2>/dev/null || echo "0")
```

### System Configuration Fixes

1. **Enabled Pi-hole logging:**
   ```bash
   sudo pihole logging on
   ```
2. **Created missing log directory:**
   ```bash
   sudo mkdir -p /var/log/pihole
   sudo chown pihole:pihole /var/log/pihole
   ```
3. **Updated blocked domains threshold:**
   - Changed from 100,000 to 1,000,000 domains.

## ✅ Results After Fix

```
Pi-hole Statistics:
Blocked Domains: 1,418,808 ✅
Queries Today: 6,718 ✅
Ads Blocked Today: 172 ✅
Blocking Rate: 2.6% ✅
```

## 📋 Testing Performed

1. **Database connectivity:**
   ```bash
   sudo sqlite3 /etc/pihole/gravity.db "SELECT COUNT(*) FROM gravity;"
   # Result: 1418808
   ```
2. **Query logging:**
   ```bash
   sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries;"
   # Result: 1149357
   ```
3. **Daily statistics:**
   ```bash
   sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE timestamp >= strftime('%s', datetime('now', 'start of day'));"
   # Result: 6718
   ```

## 🔄 Compatibility Notes

- **Pi-hole Version**: Works with v5.x and newer.
- **Database Schema**: Uses current FTL database structure.
- **Backward Compatibility**: Includes fallback error handling.

## 📝 Files Modified

- `scripts/pihole-alert.sh` - Updated database queries and paths.
- `README.md` - Updated documentation.
- `docs/PIHOLE_MONITORING_README.md` - Updated troubleshooting section.

## 🎯 Prevention

- Added error handling for database queries.
- Included database path validation.
- Updated documentation with current Pi-hole API usage.


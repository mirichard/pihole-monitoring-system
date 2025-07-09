# GitHub Issue Template

**Title:** Fix Pi-hole monitoring script for newer Pi-hole versions

**Labels:** bug, enhancement, documentation

**Body:**

## 🐛 Problem Description

The Pi-hole monitoring script was reporting incorrect statistics:
- **Blocked Domains**: 0 (should be ~1.4 million)
- **Queries Today**: 0 (should be thousands)
- **Ads Blocked Today**: 0 (should be hundreds)

**Alert Message:**
```
Pi-hole Alert Report - 2025-07-09 09:30:01

ALERTS:
WARNING: Low number of blocked domains: 0

System Status Report:
Temperature: 42.4°C
Pi-hole Statistics:
Blocked Domains: 0
Queries Today: 0
Ads Blocked Today: 0
Blocking Rate: 0%
```

## 🔍 Root Cause Analysis

### 1. **Deprecated API Usage**
- Script was using `pihole -c -j` (chronometer) which has been deprecated
- Command now returns: `Chronometer is gone, use PADD`

### 2. **Incorrect Database Path**
- Script was looking for FTL database at: `/var/log/pihole/pihole-FTL.db`
- Actual location: `/etc/pihole/pihole-FTL.db`

### 3. **Wrong Table for Blocked Domains**
- Script was checking `domainlist` table (returned 0)
- Should check `gravity` table (contains 1,418,808 domains)

### 4. **Logging Disabled**
- Pi-hole query logging was disabled
- No queries were being recorded in the database

## ✅ Solution Applied

Updated script to use direct database queries:

```bash
# New method - direct database queries
blocked_domains=$(sudo sqlite3 /etc/pihole/gravity.db "SELECT COUNT(*) FROM gravity;" 2>/dev/null || echo "0")
ads_blocked_today=$(sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE (status = 1 OR status = 4 OR status = 5 OR status = 6 OR status = 7 OR status = 8 OR status = 9 OR status = 10 OR status = 11) AND timestamp >= strftime('%s', datetime('now', 'start of day'));" 2>/dev/null || echo "0")
dns_queries_today=$(sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE timestamp >= strftime('%s', datetime('now', 'start of day'));" 2>/dev/null || echo "0")
```

## 📋 Results After Fix

```
Pi-hole Statistics:
Blocked Domains: 1,418,808 ✅
Queries Today: 6,718 ✅
Ads Blocked Today: 172 ✅
Blocking Rate: 2.6% ✅
```

## 📝 Files Modified

- `scripts/pihole-alert.sh` - Updated database queries and paths
- `README.md` - Updated documentation
- `docs/PIHOLE_MONITORING_README.md` - Updated troubleshooting section
- `docs/troubleshooting/2025-07-09_issue-resolution.md` - Detailed documentation

## 🎯 Prevention

- Added error handling for database queries
- Included database path validation
- Updated documentation with current Pi-hole API usage

**Status: RESOLVED** ✅

See detailed documentation: [docs/troubleshooting/2025-07-09_issue-resolution.md](docs/troubleshooting/2025-07-09_issue-resolution.md)

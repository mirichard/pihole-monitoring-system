#!/bin/bash

# Configuration
RECHECK_DELAY=30  # seconds to wait before rechecking a failed service
MAINTENANCE_FILE="/tmp/maintenance_mode"  # file to indicate scheduled maintenance
MAX_RETRIES=3  # maximum number of retries for service checks
LOG_FILE="/var/log/pihole-monitor.log"

# Helper functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" > /dev/null
}

is_maintenance_mode() {
    [ -f "$MAINTENANCE_FILE" ]
}

check_service_with_retry() {
    local service_name="$1"
    local check_command="$2"
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        if eval "$check_command"; then
            return 0  # Service is running
        fi
        
        retry_count=$((retry_count + 1))
        log_message "Service check failed for $service_name (attempt $retry_count/$MAX_RETRIES)"
        
        if [ $retry_count -lt $MAX_RETRIES ]; then
            log_message "Waiting ${RECHECK_DELAY}s before retrying $service_name..."
            sleep $RECHECK_DELAY
        fi
    done
    
    return 1  # Service is down after all retries
}

# Get timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Check system metrics
temp=$(vcgencmd measure_temp | sed "s/temp=//" | sed "s/'C//")
load=$(uptime | awk -F"load average:" "{print \$2}" | awk -F"," "{print \$1}" | tr -d " ")
memory_used=$(free | awk "/Mem:/ {printf(\"%d\", \$3/\$2 * 100)}")
disk_used=$(df -h / | awk "NR==2 {print \$5}" | sed "s/%//")
cpu_freq=$(vcgencmd measure_clock arm | awk -F"=" "{printf \"%.0f\", \$2 / 1000000}")
voltage=$(vcgencmd measure_volts core | sed "s/volt=//" | sed "s/V//")

# Get Pi-hole stats
blocked_domains=$(pihole -c -j 2>/dev/null | grep "domains_being_blocked" | cut -d":" -f2 | tr -d ", " | head -1)
ads_blocked_today=$(pihole -c -j 2>/dev/null | grep "ads_blocked_today" | cut -d":" -f2 | tr -d ", " | head -1)
dns_queries_today=$(pihole -c -j 2>/dev/null | grep "dns_queries_today" | cut -d":" -f2 | tr -d ", " | head -1)

# Set defaults for empty values
blocked_domains=${blocked_domains:-0}
ads_blocked_today=${ads_blocked_today:-0}
dns_queries_today=${dns_queries_today:-0}
memory_used=${memory_used:-0}
disk_used=${disk_used:-0}

# Initialize alert message
alert_message=""
maintenance_prefix=""

# Check if we're in maintenance mode
if is_maintenance_mode; then
    maintenance_prefix="[MAINTENANCE MODE] "
    log_message "Running in maintenance mode - alerts will be suppressed for service failures"
fi

# System Alerts (not affected by maintenance mode)
if (( $(echo "$temp > 65" | bc -l) )); then
    alert_message="${alert_message}CRITICAL: Temperature is ${temp}°C (>65°C)\\n"
elif (( $(echo "$temp > 60" | bc -l) )); then
    alert_message="${alert_message}WARNING: Temperature is ${temp}°C (>60°C)\\n"
fi

if (( $(echo "$load > 4" | bc -l) )); then
    alert_message="${alert_message}CRITICAL: Very high CPU load: ${load}\\n"
elif (( $(echo "$load > 2" | bc -l) )); then
    alert_message="${alert_message}WARNING: High CPU load: ${load}\\n"
fi

if [ "$memory_used" -gt 90 ]; then
    alert_message="${alert_message}CRITICAL: Memory usage at ${memory_used}%\\n"
elif [ "$memory_used" -gt 80 ]; then
    alert_message="${alert_message}WARNING: High memory usage at ${memory_used}%\\n"
fi

if [ "$disk_used" -gt 90 ]; then
    alert_message="${alert_message}CRITICAL: Disk usage at ${disk_used}%\\n"
elif [ "$disk_used" -gt 80 ]; then
    alert_message="${alert_message}WARNING: High disk usage at ${disk_used}%\\n"
fi

# Voltage check (under-voltage warning)
if (( $(echo "$voltage < 1.2" | bc -l) )); then
    alert_message="${alert_message}WARNING: Low voltage detected: ${voltage}V\\n"
fi

# Service Status Checks (with retry logic and maintenance mode awareness)
service_alerts=""

# Check Pi-hole FTL service
if ! check_service_with_retry "pihole-FTL" "pidof pihole-FTL > /dev/null"; then
    if is_maintenance_mode; then
        service_alerts="${service_alerts}${maintenance_prefix}Pi-hole FTL service is not running\\n"
        log_message "Pi-hole FTL service down - suppressed due to maintenance mode"
    else
        service_alerts="${service_alerts}CRITICAL: Pi-hole FTL service is not running (verified after retries)\\n"
        log_message "Pi-hole FTL service confirmed down after $MAX_RETRIES attempts"
    fi
fi

# Check Unbound DNS service
if ! check_service_with_retry "unbound" "systemctl is-active --quiet unbound"; then
    if is_maintenance_mode; then
        service_alerts="${service_alerts}${maintenance_prefix}Unbound DNS service is not running\\n"
        log_message "Unbound DNS service down - suppressed due to maintenance mode"
    else
        service_alerts="${service_alerts}CRITICAL: Unbound DNS service is not running (verified after retries)\\n"
        log_message "Unbound DNS service confirmed down after $MAX_RETRIES attempts"
    fi
fi

# Add service alerts to main alert message
alert_message="${alert_message}${service_alerts}"

# DNS Performance Check (with retry logic)
dns_response_total=0
dns_checks=0
for i in {1..3}; do
    dns_response=$(dig @127.0.0.1 -p 5335 google.com +noall +stats 2>/dev/null | grep "Query time:" | awk "{print \$4}")
    if [ ! -z "$dns_response" ] && [ "$dns_response" -gt 0 ] 2>/dev/null; then
        dns_response_total=$((dns_response_total + dns_response))
        dns_checks=$((dns_checks + 1))
    fi
    sleep 1
done

if [ $dns_checks -gt 0 ]; then
    dns_response_avg=$((dns_response_total / dns_checks))
    if [ "$dns_response_avg" -gt 1000 ]; then
        alert_message="${alert_message}WARNING: Slow DNS response time: ${dns_response_avg}ms (average of $dns_checks checks)\\n"
    fi
else
    dns_response_avg="N/A"
fi

# DNS Resolution Check (with retry)
dns_resolution_failed=true
for i in {1..3}; do
    if dig @127.0.0.1 -p 5335 google.com +short > /dev/null 2>&1; then
        dns_resolution_failed=false
        break
    fi
    sleep 5
done

if $dns_resolution_failed; then
    if is_maintenance_mode; then
        alert_message="${alert_message}${maintenance_prefix}DNS resolution failure (verified after retries)\\n"
    else
        alert_message="${alert_message}CRITICAL: DNS resolution failure (verified after retries)\\n"
    fi
fi

# Network Connectivity Check (with retry)
network_down=true
for i in {1..3}; do
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        network_down=false
        break
    fi
    sleep 5
done

if $network_down; then
    alert_message="${alert_message}CRITICAL: Network connectivity issue detected (verified after retries)\\n"
fi

# Pi-hole Blocking Effectiveness Check
if [ "$blocked_domains" -lt 100000 ]; then
    alert_message="${alert_message}WARNING: Low number of blocked domains: ${blocked_domains}\\n"
fi

blocking_rate=0
if [ "$dns_queries_today" -gt 0 ]; then
    blocking_rate=$(echo "scale=2; $ads_blocked_today * 100 / $dns_queries_today" | bc)
    if (( $(echo "$blocking_rate < 5" | bc -l) )); then
        alert_message="${alert_message}WARNING: Low blocking rate: ${blocking_rate}%\\n"
    fi
fi

# Send alert if there are any issues
if [ ! -z "$alert_message" ]; then
    # Prepare detailed system status
    system_status="System Status Report:
Temperature: ${temp}°C
CPU Load: ${load}
CPU Frequency: ${cpu_freq}MHz
Voltage: ${voltage}V
Memory Usage: ${memory_used}%
Disk Usage: ${disk_used}%

Pi-hole Statistics:
Blocked Domains: ${blocked_domains}
Queries Today: ${dns_queries_today}
Ads Blocked Today: ${ads_blocked_today}
Blocking Rate: ${blocking_rate}%

DNS Performance:
Response Time: ${dns_response_avg}ms

Monitoring Configuration:
Recheck Delay: ${RECHECK_DELAY}s
Max Retries: ${MAX_RETRIES}
Maintenance Mode: $(is_maintenance_mode && echo "ACTIVE" || echo "inactive")"

    # Determine subject prefix based on maintenance mode
    subject_prefix="Pi-hole Alert"
    if is_maintenance_mode; then
        subject_prefix="Pi-hole Alert [MAINTENANCE]"
    fi

    # Send email with full report
    echo -e "${subject_prefix} Report - ${timestamp}\\n\\nALERTS:\\n${alert_message}\\n${system_status}" | mail -s "${subject_prefix}: Issues Detected on $(hostname)" your-email@example.com
    
    log_message "Alert sent - Issues detected and reported"
    echo "Alert sent - Issues detected and reported"
else
    log_message "No issues detected - system running normally"
    echo "No issues detected - system running normally"
fi

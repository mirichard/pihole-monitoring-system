#!/bin/bash

# Pi-hole Monitoring System Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Installing Pi-hole Monitoring System..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  Please run this script as a regular user, not as root"
    echo "   The script will use sudo when needed"
    exit 1
fi

# Check for required commands
echo "🔍 Checking dependencies..."
MISSING_DEPS=()

for cmd in mail bc dig vcgencmd pihole systemctl; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=($cmd)
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "❌ Missing required dependencies:"
    printf "   %s\n" "${MISSING_DEPS[@]}"
    echo "   Please install them before continuing"
    exit 1
fi

echo "✅ All dependencies found"

# Install scripts
echo "📦 Installing scripts..."
sudo cp "$PROJECT_DIR/scripts/pihole-alert.sh" /usr/local/bin/
sudo cp "$PROJECT_DIR/scripts/maintenance-mode" /usr/local/bin/
sudo chmod +x /usr/local/bin/pihole-alert.sh
sudo chmod +x /usr/local/bin/maintenance-mode

# Create log file
echo "📝 Setting up log file..."
sudo touch /var/log/pihole-monitor.log
sudo chmod 644 /var/log/pihole-monitor.log

# Test installation
echo "🧪 Testing installation..."
if maintenance-mode status &>/dev/null; then
    echo "✅ maintenance-mode command working"
else
    echo "❌ maintenance-mode command failed"
    exit 1
fi

if sudo bash -n /usr/local/bin/pihole-alert.sh; then
    echo "✅ pihole-alert.sh syntax check passed"
else
    echo "❌ pihole-alert.sh syntax check failed"
    exit 1
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "1. Configure your email address in /usr/local/bin/pihole-alert.sh"
echo "2. Test the system: sudo /usr/local/bin/pihole-alert.sh"
echo "3. Set up cron job: sudo crontab -e"
echo "   Add: */5 * * * * /usr/local/bin/pihole-alert.sh"
echo ""
echo "📖 See docs/PIHOLE_MONITORING_README.md for full documentation"

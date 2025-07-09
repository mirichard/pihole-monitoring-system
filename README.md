# Pi-hole Monitoring System

A comprehensive monitoring and alerting system for Pi-hole DNS servers with intelligent retry logic and maintenance mode support.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)

## Features

🔍 **Comprehensive Monitoring**
- System health (temperature, CPU, memory, disk usage)
- Service status (Pi-hole FTL, Unbound DNS)
- DNS performance and connectivity
- Pi-hole blocking effectiveness

🔄 **Intelligent Alerting**
- Retry logic with configurable delays
- Maintenance mode to suppress alerts during planned work
- Email notifications with detailed reports
- Comprehensive logging for troubleshooting

🛠️ **Easy Management**
- Simple maintenance mode control
- Configurable alert thresholds
- Automated log rotation support
- Cron job ready

## Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/pihole-monitoring-system.git
cd pihole-monitoring-system

# Install scripts
sudo cp scripts/pihole-alert.sh /usr/local/bin/
sudo cp scripts/maintenance-mode /usr/local/bin/
sudo chmod +x /usr/local/bin/pihole-alert.sh
sudo chmod +x /usr/local/bin/maintenance-mode

# Create log file
sudo touch /var/log/pihole-monitor.log
sudo chmod 644 /var/log/pihole-monitor.log
```

### 2. Configuration

**Important:** Before using the system, you must configure your email address.

Edit `/usr/local/bin/pihole-alert.sh` and find this line:
```bash
mail -s "${subject_prefix}: Issues Detected on $(hostname)" your-email@example.com
```

Change `your-email@example.com` to your actual email address:
```bash
mail -s "${subject_prefix}: Issues Detected on $(hostname)" your-email@domain.com
```

### 3. Test the System

```bash
# Run a manual check
sudo /usr/local/bin/pihole-alert.sh

# Test maintenance mode
maintenance-mode on -t 5 -r "Testing"
maintenance-mode status
maintenance-mode off
```

### 4. Automate with Cron

```bash
# Edit crontab
sudo crontab -e

# Add this line to run every 5 minutes
*/5 * * * * /usr/local/bin/pihole-alert.sh
```

## Usage

### Basic Commands

```bash
# Run monitoring check
sudo /usr/local/bin/pihole-alert.sh

# Enable maintenance mode
maintenance-mode on -t 30 -r "System updates"

# Check status
maintenance-mode status

# Disable maintenance mode
maintenance-mode off

# View logs
sudo tail -f /var/log/pihole-monitor.log
```

### Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Temperature | >60°C | >65°C |
| CPU Load | >2.0 | >4.0 |
| Memory Usage | >80% | >90% |
| Disk Usage | >80% | >90% |
| Voltage | <1.2V | - |
| DNS Response | >1000ms | - |

## Documentation

- 📖 [Full Documentation](docs/PIHOLE_MONITORING_README.md)
- 🔧 [Quick Reference](docs/MONITORING_QUICK_REFERENCE.md)
- 💡 [Installation Examples](examples/)

## Requirements

- Raspberry Pi with Pi-hole installed
- Bash shell
- `mail` command configured for email alerts
- `bc` for mathematical calculations
- `dig` for DNS testing

## File Structure

```
pihole-monitoring-system/
├── README.md
├── LICENSE
├── scripts/
│   ├── pihole-alert.sh          # Main monitoring script
│   └── maintenance-mode         # Maintenance mode utility
├── docs/
│   ├── PIHOLE_MONITORING_README.md
│   └── MONITORING_QUICK_REFERENCE.md
└── examples/
    ├── cron-examples.txt
    ├── logrotate-config
    └── install.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter issues:

1. Check the [troubleshooting section](docs/PIHOLE_MONITORING_README.md#troubleshooting)
2. Review the log file: `sudo tail -f /var/log/pihole-monitor.log`
3. Open an issue on GitHub with relevant log entries

## Acknowledgments

- Pi-hole team for creating an excellent DNS solution
- The Raspberry Pi community for inspiration and support

---

⭐ **Star this repository if you find it helpful!**

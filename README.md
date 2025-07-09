<div align="center">

# 🛡️ Pi-hole Monitoring System

**Comprehensive monitoring and alerting system for Pi-hole DNS servers with intelligent retry logic and maintenance mode support**

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi-red.svg)](https://www.raspberrypi.org/)
[![GitHub release](https://img.shields.io/github/release/mirichard/pihole-monitoring-system.svg)](https://github.com/mirichard/pihole-monitoring-system/releases)
[![GitHub issues](https://img.shields.io/github/issues/mirichard/pihole-monitoring-system.svg)](https://github.com/mirichard/pihole-monitoring-system/issues)
[![GitHub stars](https://img.shields.io/github/stars/mirichard/pihole-monitoring-system.svg)](https://github.com/mirichard/pihole-monitoring-system/stargazers)

[Quick Start](#-quick-start) • [Features](#-features) • [Documentation](#-documentation) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

Keep your Pi-hole DNS server running smoothly with automated monitoring, intelligent alerting, and maintenance mode support. This system provides comprehensive health checks, retry logic to prevent false alarms, and easy maintenance management.

## ✨ Features

### 🔍 **Comprehensive Monitoring**
- **System Health**: Temperature, CPU load, memory usage, disk space
- **Service Status**: Pi-hole FTL, Unbound DNS service monitoring
- **DNS Performance**: Query response times and resolution testing
- **Network Connectivity**: External connectivity verification
- **Pi-hole Metrics**: Blocking effectiveness and domain statistics

### 🔄 **Intelligent Alerting**
- **Retry Logic**: Configurable delays and retry attempts to prevent false alarms
- **Maintenance Mode**: Suppress service alerts during planned maintenance
- **Email Notifications**: Detailed reports with system status
- **Comprehensive Logging**: Full audit trail for troubleshooting

### 🛠️ **Easy Management**
- **Simple Setup**: One-command installation script
- **Maintenance Control**: Easy enable/disable maintenance mode
- **Configurable Thresholds**: Customize alert levels for your environment
- **Cron Ready**: Automated scheduling support

## 📊 Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| 🌡️ Temperature | >60°C | >65°C |
| 💻 CPU Load | >2.0 | >4.0 |
| 🧠 Memory Usage | >80% | >90% |
| 💾 Disk Usage | >80% | >90% |
| ⚡ Voltage | <1.2V | - |
| 🌐 DNS Response | >1000ms | - |
| 🚫 Blocked Domains | <100,000 | - |
| 📈 Blocking Rate | <5% | - |

## 🚀 Quick Start

### Prerequisites
- Raspberry Pi with Pi-hole installed
- Bash shell environment
- Mail system configured (postfix, sendmail, etc.)
- Basic utilities: `bc`, `dig`, `vcgencmd`

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/mirichard/pihole-monitoring-system.git
cd pihole-monitoring-system

# 2. Run the installation script
./examples/install.sh

# 3. Configure your email address
sudo nano /usr/local/bin/pihole-alert.sh
# Change: your-email@example.com to your actual email

# 4. Test the system
sudo /usr/local/bin/pihole-alert.sh

# 5. Set up automated monitoring (optional)
sudo crontab -e
# Add: */5 * * * * /usr/local/bin/pihole-alert.sh
```

## 📖 Usage

### Basic Commands

```bash
# Run monitoring check
sudo /usr/local/bin/pihole-alert.sh

# Enable maintenance mode (60 min default)
maintenance-mode on

# Enable with custom duration and reason
maintenance-mode on -t 30 -r "System updates"

# Check maintenance status
maintenance-mode status

# Disable maintenance mode
maintenance-mode off

# View recent logs
sudo tail -f /var/log/pihole-monitor.log
```

### Sample Alert Email

```
Subject: Pi-hole Alert: Issues Detected on raspberry-pi

Pi-hole Alert Report - 2025-07-09 08:52:19

ALERTS:
WARNING: High memory usage at 85%
CRITICAL: Pi-hole FTL service is not running (verified after retries)

System Status Report:
Temperature: 45.2°C
CPU Load: 1.2
Memory Usage: 85%
Disk Usage: 45%
...
```

## 🗂️ Project Structure

```
pihole-monitoring-system/
├── 📄 README.md                          # This file
├── 📜 LICENSE                            # MIT License
├── 🙈 .gitignore                        # Git ignore rules
├── 📁 scripts/
│   ├── 🔍 pihole-alert.sh               # Main monitoring script
│   └── 🛠️ maintenance-mode              # Maintenance mode utility
├── 📁 docs/
│   ├── 📖 PIHOLE_MONITORING_README.md   # Comprehensive documentation
│   └── 📋 MONITORING_QUICK_REFERENCE.md # Quick reference guide
└── 📁 examples/
    ├── 🚀 install.sh                    # Installation script
    ├── ⏰ cron-examples.txt              # Cron job examples
    └── 🔄 logrotate-config              # Log rotation configuration
```

## 📚 Documentation

- 📖 [**Complete Documentation**](docs/PIHOLE_MONITORING_README.md) - Detailed setup, configuration, and troubleshooting
- 📋 [**Quick Reference**](docs/MONITORING_QUICK_REFERENCE.md) - Commands and thresholds at a glance
- 💾 [**Installation Guide**](examples/install.sh) - Automated setup script
- ⏰ [**Cron Examples**](examples/cron-examples.txt) - Scheduling configurations

## 🔧 Configuration

### Email Setup
Edit `/usr/local/bin/pihole-alert.sh` and update the email address:

```bash
# Find this line:
mail -s "${subject_prefix}: Issues Detected on $(hostname)" your-email@example.com

# Change to:
mail -s "${subject_prefix}: Issues Detected on $(hostname)" your-email@domain.com
```

### Monitoring Intervals
Common cron configurations:

```bash
# Every 5 minutes
*/5 * * * * /usr/local/bin/pihole-alert.sh

# Every 15 minutes
*/15 * * * * /usr/local/bin/pihole-alert.sh

# Business hours only (8 AM - 6 PM)
*/5 8-18 * * * /usr/local/bin/pihole-alert.sh
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Bug Reports
- Use the [issue tracker](https://github.com/mirichard/pihole-monitoring-system/issues)
- Include system information and log excerpts
- Describe expected vs actual behavior

### 💡 Feature Requests
- Check [existing issues](https://github.com/mirichard/pihole-monitoring-system/issues) first
- Describe the use case and proposed solution
- Consider backward compatibility

### 🔧 Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🆘 Support

### Getting Help
1. 📖 Check the [documentation](docs/PIHOLE_MONITORING_README.md)
2. 🔍 Search [existing issues](https://github.com/mirichard/pihole-monitoring-system/issues)
3. 📝 Create a [new issue](https://github.com/mirichard/pihole-monitoring-system/issues/new) with:
   - System information
   - Log excerpts
   - Steps to reproduce

### Troubleshooting
```bash
# Check log file for errors
sudo tail -50 /var/log/pihole-monitor.log

# Test individual components
pidof pihole-FTL
systemctl is-active unbound
dig @127.0.0.1 -p 5335 google.com

# Verify script syntax
bash -n /usr/local/bin/pihole-alert.sh
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

- **Pi-hole Team** - For creating an excellent DNS solution
- **Raspberry Pi Foundation** - For the amazing hardware platform
- **Open Source Community** - For inspiration and contributions

## 🌟 Show Your Support

If this project helps you, please consider:

- ⭐ **Starring** the repository
- 🐛 **Reporting** bugs and issues
- 💡 **Suggesting** new features
- 🔧 **Contributing** code improvements
- 📢 **Sharing** with others who might benefit

---

<div align="center">

**Made with ❤️ for the Pi-hole community**

[⬆ Back to Top](#️-pi-hole-monitoring-system)

</div>

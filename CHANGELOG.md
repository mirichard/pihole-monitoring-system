# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-07-09

### Added
- **Intelligent Retry Logic**: Services are now checked multiple times before alerting
- **Maintenance Mode**: Suppress service alerts during planned maintenance
- **Comprehensive Logging**: Full audit trail in `/var/log/pihole-monitor.log`
- **Maintenance Mode Utility**: Easy-to-use `maintenance-mode` command
- **Enhanced Documentation**: Complete setup and troubleshooting guides
- **Installation Script**: Automated setup with dependency checking
- **Configuration Examples**: Cron jobs, log rotation, and more

### Changed
- **Improved Alert Accuracy**: Reduced false positives with retry logic
- **Enhanced Email Reports**: More detailed system status information
- **Better Error Handling**: Graceful handling of service failures
- **Configurable Thresholds**: Easier to customize for different environments

### Fixed
- **DNS Performance Monitoring**: More reliable response time measurements
- **Service Status Checks**: Better detection of service states
- **Temperature Monitoring**: More accurate readings and thresholds

## [1.0.0] - 2025-07-08

### Added
- **Initial Release**: Basic Pi-hole monitoring system
- **System Health Monitoring**: Temperature, CPU, memory, disk usage
- **Service Monitoring**: Pi-hole FTL and Unbound DNS
- **Email Alerts**: Basic notification system
- **DNS Performance Testing**: Query response time monitoring
- **Network Connectivity Checks**: External connectivity verification
- **Pi-hole Statistics**: Blocking effectiveness monitoring

### Features
- System temperature monitoring with configurable thresholds
- CPU load monitoring and alerting
- Memory usage tracking
- Disk space monitoring
- Voltage monitoring for Raspberry Pi
- DNS resolution testing
- Pi-hole blocking statistics
- Email notification system
- Basic logging functionality

---

## Version History

- **v2.0.0**: Added retry logic and maintenance mode support
- **v1.0.0**: Initial monitoring system release

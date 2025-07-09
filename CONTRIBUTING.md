# Contributing to Pi-hole Monitoring System

First off, thank you for considering contributing to the Pi-hole Monitoring System! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to creating a welcoming and inclusive environment. Please be respectful and professional in all interactions.

## Getting Started

### Prerequisites

- Raspberry Pi with Pi-hole installed
- Basic knowledge of Bash scripting
- Git for version control
- Text editor of your choice

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/pihole-monitoring-system.git
   cd pihole-monitoring-system
   ```
3. **Create a development branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### 🐛 Bug Reports

When reporting bugs, please include:

- **System Information**: OS version, Pi-hole version, hardware details
- **Log Excerpts**: Relevant entries from `/var/log/pihole-monitor.log`
- **Steps to Reproduce**: Clear, step-by-step instructions
- **Expected vs Actual Behavior**: What should happen vs what actually happens
- **Screenshots**: If applicable

### 💡 Feature Requests

For new features:

- **Check existing issues** to avoid duplicates
- **Describe the use case** and problem it solves
- **Propose a solution** if you have ideas
- **Consider backward compatibility**

### 🔧 Code Contributions

Areas where contributions are especially welcome:

- **Additional monitoring checks** (new services, metrics)
- **Alert integrations** (Slack, Discord, webhooks)
- **Platform support** (other Linux distributions)
- **Documentation improvements**
- **Test coverage** and validation scripts
- **Performance optimizations**

## Submitting Changes

### Pull Request Process

1. **Update documentation** if needed
2. **Test your changes** thoroughly
3. **Update CHANGELOG.md** with your changes
4. **Ensure code follows style guidelines**
5. **Submit pull request** with clear description

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (please describe)

## Testing
- [ ] Tested on Raspberry Pi
- [ ] Tested with Pi-hole
- [ ] No breaking changes
- [ ] Documentation updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] CHANGELOG.md updated
```

## Style Guidelines

### Bash Scripting Standards

- **Use `#!/bin/bash`** as shebang
- **4-space indentation** (no tabs)
- **Descriptive variable names** in lowercase with underscores
- **Function names** in lowercase with underscores
- **Comments** for complex logic and functions
- **Error handling** with proper exit codes
- **Quoting** variables to prevent word splitting

### Example Code Style

```bash
#!/bin/bash

# Configuration variables
RETRY_DELAY=30
MAX_RETRIES=3

# Function to check service status
check_service_status() {
    local service_name="$1"
    local check_command="$2"
    
    if eval "$check_command"; then
        log_message "Service $service_name is running"
        return 0
    else
        log_message "Service $service_name is not running"
        return 1
    fi
}
```

### Documentation Standards

- **Clear headings** with proper hierarchy
- **Code examples** with syntax highlighting
- **Step-by-step instructions** for complex procedures
- **Cross-references** to related sections
- **Screenshots** where helpful

## Testing

### Manual Testing

Before submitting changes:

1. **Test on Raspberry Pi** with Pi-hole installed
2. **Verify all monitoring functions** work correctly
3. **Test maintenance mode** functionality
4. **Check email notifications** are sent properly
5. **Validate log file** entries are correct

### Test Scenarios

- **Normal operation** - All services running
- **Service failures** - Pi-hole FTL down, Unbound down
- **System stress** - High CPU, memory, temperature
- **Network issues** - DNS resolution failures
- **Maintenance mode** - Alerts properly suppressed

### Automated Testing

We welcome contributions for:

- **Unit tests** for individual functions
- **Integration tests** for full system testing
- **Performance tests** for resource usage
- **Validation scripts** for configuration

## Development Workflow

### Branch Naming

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code improvements

### Commit Messages

Use clear, descriptive commit messages:

```
Add retry logic for DNS resolution checks

- Implement 3-retry mechanism for DNS queries
- Add configurable delay between retries
- Update documentation with new configuration options
```

### Code Review Process

1. **All changes** require review before merging
2. **Address feedback** promptly and professionally
3. **Maintain discussion** in pull request comments
4. **Squash commits** if requested before merging

## Getting Help

If you need help with contributions:

- 📖 Check the [documentation](docs/PIHOLE_MONITORING_README.md)
- 💬 Open a [discussion](https://github.com/mirichard/pihole-monitoring-system/discussions)
- 🐛 Create an [issue](https://github.com/mirichard/pihole-monitoring-system/issues) for bugs
- 📧 Contact maintainers through GitHub

## Recognition

Contributors will be recognized in:

- **README.md** acknowledgments section
- **CHANGELOG.md** for significant contributions
- **GitHub contributors** page
- **Release notes** for major features

---

Thank you for contributing to the Pi-hole Monitoring System! 🚀

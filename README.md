# Server Setup Script

This repository contains a comprehensive server setup script designed to streamline the installation and configuration of essential packages and tools on major Linux distributions including Ubuntu, CentOS, Fedora, and Debian. 

## Features

- Automatically detects the operating system and installs packages accordingly
- Installs essential tools and libraries such as Vim, Git, Docker, Nginx, MySQL, PHP, and more
- Installs tools from source, including massdns, masscan, waymore, and others
- Installs Rust and various Rust-based tools
- Installs Go and various Go-based tools
- Configures Cloudflare Warp

## Supported Distributions

- Ubuntu
- CentOS
- Fedora
- Debian

## Usage

1. Clone this repository to your server:
    ```bash
    git clone https://github.com/yourusername/server-setup-script.git
    cd server-setup-script
    ```

2. Make the script executable:
    ```bash
    chmod +x setup.sh
    ```

3. Run the script:
    ```bash
    sudo ./setup.sh
    ```

## Script Details

### Operating System Detection

The script automatically detects the operating system using `/etc/os-release` and runs the appropriate package installation commands for the detected OS.

### Tools Installation

For a detailed list of tools that are installed, please refer to the [TOOLS.md](TOOLS.md) file.

## Customization

You can customize the script to add or remove packages and tools as needed. The functions for installing packages and tools are modular, making it easy to modify for your specific requirements.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

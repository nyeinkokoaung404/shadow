#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 1>&2
   exit 1
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
apt-get update
apt-get install -y wget curl nano unzip git openssh-server dropbear stunnel4 openvpn easy-rsa fail2ban squid3 apache2

# Clone repository
echo -e "${YELLOW}Cloning SSH Panel repository...${NC}"
git clone https://github.com/yourusername/ssh-panel.git /etc/ssh-panel

# Setup web interface
echo -e "${YELLOW}Setting up web interface...${NC}"
cp -r /etc/ssh-panel/web/* /var/www/html/
chown -R www-data:www-data /var/www/html

# Setup SSH configurations
echo -e "${YELLOW}Configuring SSH services...${NC}"
cp /etc/ssh-panel/config/sshd_config /etc/ssh/sshd_config
cp /etc/ssh-panel/config/dropbear /etc/default/dropbear

# Setup OpenVPN
echo -e "${YELLOW}Setting up OpenVPN...${NC}"
cp -r /etc/ssh-panel/openvpn /etc/openvpn/server
cd /etc/openvpn/server && ./setup.sh

# Setup database
echo -e "${YELLOW}Setting up user database...${NC}"
cp /etc/ssh-panel/database/ssh-users.db /etc/ssh/
chmod 600 /etc/ssh/ssh-users.db

# Start services
echo -e "${YELLOW}Starting services...${NC}"
systemctl restart ssh
systemctl restart dropbear
systemctl restart openvpn-server@server
systemctl restart apache2
systemctl restart squid

echo -e "${GREEN}Installation completed!${NC}"
echo -e "${BLUE}Access your panel at: http://your-server-ip/${NC}"

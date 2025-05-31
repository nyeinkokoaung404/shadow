#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 1>&2
   exit 1
fi

# Get user input
read -p "Enter username: " username
read -p "Enter password: " password
read -p "Enter expiration date (YYYY-MM-DD): " expiry
read -p "Enter connection limit: " limit

# Add user
useradd -e $expiry -s /bin/false -M $username
echo -e "$password\n$password" | passwd $username &> /dev/null

# Add to database
echo "$username:$password:$expiry:$limit" >> /etc/ssh/ssh-users.db

echo -e "${GREEN}User $username added successfully!${NC}"

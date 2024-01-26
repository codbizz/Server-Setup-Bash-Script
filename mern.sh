#!/bin/bash

# Update apt package manager
sudo apt update

# Install Node.js and npm
echo "Choose Node.js version to install (enter the number):
1) Latest (default)
2) 14.x
3) 16.x
4) 18.x"
read -p "Enter the number: " NODE_VERSION_CHOICE

# Set default Node.js version
NODE_VERSION="14.x"

case $NODE_VERSION_CHOICE in
    1) NODE_VERSION="";; # Latest version
    2) NODE_VERSION="14.x";;
    3) NODE_VERSION="16.x";;
    4) NODE_VERSION="18.x";;
    *) echo "Invalid choice. Installing the latest version.";;
esac

curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash -
sudo apt install -y nodejs

# Check if npm version 20.* is requested
echo "Choose npm version to install (enter the number):
1) 20.* (default)
2) Skip"
read -p "Enter the number: " NPM_VERSION_CHOICE

case $NPM_VERSION_CHOICE in
    1) npm install -g npm@20.*;; # Install npm version 20.*
    2) echo "Skipping npm installation.";;
    *) echo "Invalid choice. Skipping npm installation.";;
esac

# Install MongoDB
sudo apt install -y mongodb

# Start MongoDB service
sudo systemctl start mongodb

# Enable MongoDB to start on boot
sudo systemctl enable mongodb

echo "Setup complete. Node.js, npm, and MongoDB are installed. You can now start using them for your projects."

#!/bin/bash

# Update apt package manager
echo "Updating apt package manager..."
sudo apt update

# Install Apache web server
echo "Installing Apache web server..."
sudo apt install apache2 -y

# Install MySQL database server
echo "Installing MySQL database server..."
sudo apt install mysql-server -y

# Ask user if they want to run MySQL secure installation
read -p "Do you want to secure your MySQL installation? (y/n): " SECURE_MYSQL

if [ "$SECURE_MYSQL" == "y" ]; then
    sudo mysql_secure_installation
fi

# Ask user to choose PHP version
echo "Choose PHP version to install (enter the number):
1) PHP 7.0
2) PHP 7.2
3) PHP 8.0
4) PHP 8.1
5) PHP 8.2"
read -p "Enter the number: " PHP_VERSION

# Install PHP and required modules based on user's choice
case $PHP_VERSION in
    1) PHP_VERSION="7.0";;
    2) PHP_VERSION="7.2";;
    3) PHP_VERSION="8.0";;
    4) PHP_VERSION="8.1";;
    5) PHP_VERSION="8.2";;
    *) echo "Invalid choice. Exiting."; exit 1;;
esac

echo "Installing PHP and required modules..."
sudo apt install php$PHP_VERSION libapache2-mod-php$PHP_VERSION php$PHP_VERSION-mysql -y

# Ask if user wants to install Laravel required extensions
read -p "Do you want to install Laravel required extensions? (y/n): " INSTALL_LARAVEL_EXTENSIONS

if [ "$INSTALL_LARAVEL_EXTENSIONS" == "y" ]; then
    echo "Installing Laravel required extensions..."
    sudo apt install php$PHP_VERSION-curl php$PHP_VERSION-mbstring -y
fi

# Restart Apache web server
echo "Restarting Apache web server..."
sudo systemctl restart apache2

# Ask user if they want to create a new database
read -p "Do you want to create a new MySQL database? (y/n): " CREATE_DATABASE

if [ "$CREATE_DATABASE" == "y" ]; then
    # Prompt for database name and user credentials
    read -p "Enter the new database name: " DB_NAME
    read -p "Enter the database user: " DB_USER
    read -sp "Enter the database user password: " DB_PASSWORD
    echo # Move to a new line after password input

    # Create the new database and user
    sudo mysql -e "CREATE DATABASE $DB_NAME;"
    sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES"

    echo "Database '$DB_NAME' and user '$DB_USER' created successfully."
fi


echo "Setup complete. You can now start your Laravel project. If you miss any required PHP extensions, install them using 'sudo apt install php$PHP_VERSION-extension_name'."

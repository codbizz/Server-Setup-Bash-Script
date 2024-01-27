##!/bin/bash

# Ask if Apache should be installed
read -p "Do you want to install Apache web server? (y/n): " INSTALL_APACHE

if [ "$INSTALL_APACHE" = "y" ]; then
    echo "Updating apt package manager..."
    sudo apt update

    echo "Installing Apache web server..."
    sudo apt install apache2 -y
fi

# Ask if MySQL should be installed
read -p "Do you want to install MySQL database server? (y/n): " INSTALL_MYSQL

if [ "$INSTALL_MYSQL" = "y" ]; then
    echo "Installing MySQL database server..."
    sudo apt install mysql-server -y
fi

# Ask user if they want to run MySQL secure installation
read -p "Do you want to secure your MySQL installation? (y/n): " SECURE_MYSQL

if [ "$SECURE_MYSQL" = "y" ]; then
    sudo mysql_secure_installation
fi

# Ask if PHP should be installed
read -p "Do you want to install PHP and required modules? (y/n): " INSTALL_PHP

if [ "$INSTALL_PHP" = "y" ]; then
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

    if [ "$INSTALL_LARAVEL_EXTENSIONS" = "y" ]; then
        echo "Installing Laravel required extensions..."
        sudo apt install php$PHP_VERSION-curl php$PHP_VERSION-mbstring php$PHP_VERSION-zip php$PHP_VERSION-xml -y
    fi
fi

# Restart Apache web server
echo "Restarting Apache web server..."
sudo systemctl restart apache2

read -p "Do you want to install Composer? (y/n): " INSTALL_COMPOSER

if [ "$INSTALL_COMPOSER" = "y" ]; then
    echo "Installing Composer..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --quiet
    RESULT=$?
    rm composer-setup.php
    sudo mv composer.phar /usr/local/bin/composer

    echo "Composer installed."
fi

# Ask if Git should be installed
read -p "Do you want to install Git? (y/n): " INSTALL_GIT

if [ "$INSTALL_GIT" = "y" ]; then
    sudo apt install git -y
fi

# GitLab repository clone
read -p "Enter the GitLab clone URL of your Laravel project: " GITLAB_CLONE_URL

# Ask for folder name or clone directly into /var/www/html
read -p "Enter the folder name (leave blank to clone directly into /var/www/html): " FOLDER_NAME

if [ -z "$FOLDER_NAME" ]; then
    TARGET_DIRECTORY="/var/www/html"
else
    TARGET_DIRECTORY="/var/www/html/$FOLDER_NAME"

    sudo mkdir -p "$TARGET_DIRECTORY"
fi

# Check if the target directory is not empty
if [ "$(ls -A "$TARGET_DIRECTORY")" ]; then
    read -p "$TARGET_DIRECTORY is not empty. Do you want to remove its contents? (y/n): " REMOVE_CONTENTS

    if [ "$REMOVE_CONTENTS" = "y" ]; then
        # Remove contents of the target directory
        sudo rm -rf "$TARGET_DIRECTORY"/*
    else
        echo "Aborting. Please empty the $TARGET_DIRECTORY directory before proceeding."
        exit 1
    fi
fi

# Clone the GitLab repository
sudo git clone $GITLAB_CLONE_URL "$TARGET_DIRECTORY"

# Change ownership of the target directory to your user
sudo chown -R $USER:$USER "$TARGET_DIRECTORY"

sudo git config --global --add safe.directory "$TARGET_DIRECTORY"

read -p "Do you want to run setup laravel project? (y/n): " SETUP_LARAVEL

if [ "$SETUP_LARAVEL" = "y" ]; then
    # Navigate to the target directory
    cd "$TARGET_DIRECTORY"

    # Run 'composer install'
    composer install
    cp .env.example .env
    php artisan key:generate
fi

echo "Setup complete. You can now start your Laravel project."

#!/usr/bin/env bash
set -e

echo "🚀 Starting Moodle setup without Docker..."

# Ensure passwordless sudo for vscode
echo "🔧 Configuring sudo permissions..."
echo "vscode ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-vscode-nopasswd > /dev/null
sudo chmod 440 /etc/sudoers.d/90-vscode-nopasswd

# Ensure we are in the workspace folder
cd /workspaces/moodle-docker

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y apache2 mariadb-server php php-mysql php-xml php-mbstring php-zip php-intl php-curl php-gd git unzip

# Start services
sudo service apache2 start
sudo service mariadb start

# Configure MariaDB
echo "🛠️ Configuring MariaDB..."
sudo mysql -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'moodle';"
sudo mysql -e "GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost'; FLUSH PRIVILEGES;"

# Install Moodle
echo "⬇️ Cloning Moodle..."
sudo mkdir -p /var/www/html/moodle
sudo git clone -b MOODLE_404_STABLE https://github.com/moodle/moodle.git /var/www/html/moodle
sudo chown -R www-data:www-data /var/www/html/moodle

# Create dataroot
sudo mkdir -p /var/moodledata
sudo chown -R www-data:www-data /var/moodledata

# Create config.php
echo "⚙️ Creating config.php..."
sudo -u www-data php /var/www/html/moodle/admin/cli/install.php \
    --wwwroot="http://localhost" \
    --dataroot="/var/moodledata" \
    --dbtype="mariadb" \
    --dbhost="localhost" \
    --dbname="moodle" \
    --dbuser="moodle" \
    --dbpass="moodle" \
    --fullname="Moodle Codespaces" \
    --shortname="Moodle" \
    --adminuser="admin" \
    --adminpass="Start123!" \
    --non-interactive

# Configure Apache
echo "🌍 Configuring Apache..."
sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/moodle
    <Directory /var/www/html/moodle>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF'

sudo a2enmod rewrite
sudo service apache2 restart

echo "✅ Moodle is ready!"
echo "🌐 Open your Codespace port 80 → then click the public URL shown in 'PORTS' tab."
echo "👤 Login: admin / Start123!"

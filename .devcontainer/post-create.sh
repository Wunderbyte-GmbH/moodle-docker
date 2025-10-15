#!/usr/bin/env bash
set -e

echo "🚀 Setting up Moodle-Docker…"

cd /workspaces/moodle-docker

# Copy environment file if missing
if [ ! -f .env ]; then
  cp env.dist .env
fi

# --- Moodle setup variables ---
export MOODLE_DOCKER_WWWROOT=/var/www/html/moodle
export MOODLE_DOCKER_DB=mariadb
export MOODLE_BRANCH=MOODLE_404_STABLE
export MOODLE_REPO=https://github.com/moodle/moodle.git
export MOODLE_DOCKER_PHP_VERSION=8.1
export MOODLE_DOCKER_BROWSER=firefox

# --- Start containers ---
echo "🐳 Starting Docker services..."
docker-compose pull
docker-compose up -d

# Wait until DB is ready
echo "⏳ Waiting for database..."
sleep 25

# --- Install Moodle inside the container ---
echo "📦 Installing Moodle..."
docker-compose exec -T webserver bash -c "
    if [ ! -d /var/www/html/moodle ]; then
        git clone -b \$MOODLE_BRANCH \$MOODLE_REPO /var/www/html/moodle
    fi &&
    cd /var/www/html/moodle &&
    php admin/cli/install.php --wwwroot=http://localhost \
        --dataroot=/var/www/moodledata \
        --dbtype=mariadb --dbhost=mariadb \
        --dbname=moodle --dbuser=moodle --dbpass=moodle \
        --fullname='Moodle Dev' --shortname='Moodle' \
        --adminuser=admin --adminpass='Start123!' --non-interactive
"

# --- Reset admin password (idempotent) ---
echo "🔑 Resetting admin password..."
docker-compose exec -T webserver bash -c "
    cd /var/www/html/moodle &&
    php admin/cli/reset_password.php --username=admin --password='Start123!'
"

echo "✅ Moodle is installed and ready at http://localhost (user: admin / Start123!)"

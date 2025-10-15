#!/usr/bin/env bash
set -e

echo "🚀 Setting up Moodle-Docker..."

# Move into the repo
cd /workspaces/moodle-docker

# Create .env if it doesn’t exist
if [ ! -f .env ]; then
  cp env.dist .env
fi

# Set the Moodle branch and repo
export MOODLE_DOCKER_WWWROOT=/var/www/html/moodle
export MOODLE_DOCKER_DB=mariadb
export MOODLE_BRANCH=MOODLE_404_STABLE
export MOODLE_REPO=https://github.com/moodle/moodle.git

# Build and start containers
docker-compose up -d

# Wait for services
sleep 10

echo "💡 Moodle-Docker environment started."

# (Optional) Example of changing the Moodle admin password once installed
# php admin/cli/reset_password.php --username=admin --password=NewSecurePassword123

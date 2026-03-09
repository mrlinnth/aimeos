#!/bin/bash
set -e

# Generate .env from Docker environment variables if missing
if [ ! -f /var/www/html/.env ]; then
    echo "No .env file found - generating from environment variables..."
    printenv | grep -v '^_=' | sort > /var/www/html/.env
    echo "Generated .env file"
fi

# Wait for database to be ready
echo "Waiting for database..."
until php artisan db:show 2>/dev/null; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is up - executing commands"

# Run Laravel setup commands
php artisan storage:link
php artisan migrate --force

# Publish vendor assets (Aimeos CSS/JS/images)
php artisan vendor:publish --all --force

# Setup Aimeos tables and initial data
php artisan aimeos:setup

# Clear all caches (config, route, view, etc.)
echo "Clearing all caches..."
php artisan optimize:clear

# Display configuration for debugging
echo "=== Configuration Check ==="
echo "APP_ENV: ${APP_ENV:-not set}"
echo "APP_URL: ${APP_URL:-not set}"
echo "SHOP_MULTILOCALE: ${SHOP_MULTILOCALE:-false}"
echo "SHOP_MULTISHOP: ${SHOP_MULTISHOP:-false}"
echo "==========================="

# Fix permissions for Laravel directories
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
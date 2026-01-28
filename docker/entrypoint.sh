#!/bin/bash
set -e

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

# Cache optimization for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permissions for Laravel directories
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
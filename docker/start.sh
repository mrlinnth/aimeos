#!/bin/sh

# Wait for database
echo "Waiting for database..."
while ! mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; do
    sleep 1
done
echo "Database is ready!"

# Run migrations
php artisan migrate --force

# Setup Aimeos (creates tables if needed)
php artisan aimeos:setup

# Clear and cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

#!/bin/sh
set -e  # Exit on any error

# Wait for database with timeout
echo "Waiting for database..."
TIMEOUT=60
COUNTER=0
while ! mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; do
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt $TIMEOUT ]; then
        echo "Database not available after ${TIMEOUT}s"
        exit 1
    fi
    sleep 1
done
echo "Database is ready!"

# Setup Aimeos (creates tables if needed)
php artisan aimeos:setup

# Clear and cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Graceful shutdown handler
shutdown() {
    echo "Received SIGTERM, shutting down gracefully..."
    supervisorctl stop all
    exit 0
}
trap shutdown SIGTERM SIGINT

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

# Docker Guide

## Quick Start with Docker

```bash
# Clone the repository
git clone <repository-url>
cd aimeos

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials
# Set APP_KEY, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_ROOT_PASSWORD

# Build and start containers
docker-compose up -d

# Run initial setup (first time only)
docker exec <app-container> php artisan migrate --force
docker exec <app-container> php artisan aimeos:setup
# with demo data
# docker exec <app-container> php artisan aimeos:setup --option=setup/default/demo:1
docker exec <app-container> php artisan aimeos:account --super admin@example.com
```

Access the application:
- Frontend: http://localhost
- Admin: http://localhost/admin
- Health check: http://localhost/health

## Deployment to Dokploy

1. Configure Dokploy with git repository URL
2. Set environment variables in Dokploy dashboard
3. Configure secrets (APP_KEY, DB_PASSWORD, DB_ROOT_PASSWORD)
4. Set up persistent volumes (mysql_data, storage, aimeos_files, redis_data)
5. Deploy application
6. Run post-deployment commands:

```bash
dokploy exec <app> php artisan migrate --force
dokploy exec <app> php artisan aimeos:setup
dokploy exec <app> php artisan aimeos:account --super admin@example.com
```

## Docker Services

- **app**: PHP-FPM + Nginx + Supervisor (port 80)
- **db**: MySQL 8.0 (port 3306)
- **redis**: Redis 7 for caching and sessions

## Health Checks

All services include health checks for monitoring:
- App: HTTP health endpoint
- Database: MySQL ping
- Redis: Redis ping

## Testing

```bash
# Run all tests
./vendor/bin/phpunit

# Run specific suite
./vendor/bin/phpunit --testsuite=Feature

# Code style
./vendor/bin/pint
```

## Important Notes

### Migrations

Migrations are not run automatically on container start to prevent race conditions. Run them manually during deployment:

```bash
php artisan migrate --force
```

### Background Jobs

The Aimeos job scheduler runs automatically via Supervisor for order processing, email notifications, and payment handling.

### Volumes

Critical persistent volumes:
- `mysql_data`: Database
- `storage`: Laravel logs and cache
- `aimeos_files`: Product images and uploads
- `redis_data`: Redis persistence

Backup these volumes regularly.

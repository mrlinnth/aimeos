# Aimeos Laravel E-commerce - Dokploy Ready

This is a fork of [aimeos/aimeos](https://github.com/aimeos/aimeos) with custom Docker configuration optimized for Dokploy deployment.

## What This Is

A production-ready Laravel 12 e-commerce application powered by Aimeos, packaged with Docker for easy deployment on Dokploy or any Docker-based platform.

## Key Features

- Laravel 12 + Aimeos e-commerce framework
- Multi-vendor marketplace support
- Multi-language and multi-shop capabilities
- JSON REST API and GraphQL admin API
- Laravel Breeze authentication
- Docker-based deployment with health checks
- Redis caching and sessions
- Supervisor process management

## Requirements

- PHP 8.2+
- MySQL 8.0
- Redis 7 (optional)
- Docker and Docker Compose (optional for local development)

## Local Development

```bash
# Clone the repository
git clone <repository-url>
cd aimeos

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials
# Set APP_KEY, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_ROOT_PASSWORD

# Install dependencies
composer install
npm install

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Aimeos setup with demo data
php artisan aimeos:setup --option=setup/default/demo:1

# Create super admin user
php artisan aimeos:account --super admin@example.com
```

## Local Server using default PHP

```bash
# Start development server
php artisan serve

# Frontend assets (separate terminal)
npm run dev
```

Access the application:
- Frontend: http://127.0.0.1:8000
![Frontend](/public/demo-store.png)
- Admin: http://127.0.0.1:8000/admin
![Admin](/public/demo-admin.png)
- Health check: http://127.0.0.1:8000/health

### Recommended Local Dev Environment Tools

1. Laragon, WAMP (Windows)
2. Laravel Valet, Herd Lite (Mac)
3. Docker (Linux, Windows, Mac)
4. Valet Linux Plus, Ddev (Linux)

## Configuration

### Multi-Language

Enable locale-based routing in `.env`:

```
SHOP_MULTILOCALE=true
```

### Multi-Vendor/SaaS Mode

Enable multi-shop features in `.env`:

```
SHOP_MULTISHOP=true
SHOP_REGISTRATION=true
SHOP_PERMISSION=admin
```

### Performance

For production, set in `.env`:

```
APP_ENV=production
APP_DEBUG=false
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

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

## Architecture

- **Backend**: Laravel 12, PHP 8.2, Aimeos package
- **Frontend**: Vite, Tailwind CSS, Laravel Breeze
- **Database**: MySQL 8.0
- **Cache/Sessions**: Redis 7
- **Web Server**: Nginx
- **Process Manager**: Supervisor

## Documentation

- [Aimeos Documentation](https://aimeos.org/docs/latest/laravel)
- [Laravel Documentation](https://laravel.com/docs)
- [Deployment Guide](CLAUDE.md)

## Support

For Aimeos-specific questions, visit the [Aimeos forum](https://aimeos.org/help/).

## License

MIT and LGPLv3

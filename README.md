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
php artisan aimeos:account --super admin@mail.com
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
SHOP_PERMISSION=admin
SHOP_REGISTRATION=true # false if you do not need shop registration
```

### Performance

For production, set in `.env`:

```
APP_ENV=production
APP_DEBUG=false
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

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
- [Docker Guide](DOCKER.md)
- [Deployment Guide](CLAUDE.md)

## Support

For Aimeos-specific questions, visit the [Aimeos forum](https://aimeos.org/help/).

## License

MIT and LGPLv3

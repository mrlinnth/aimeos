# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **fork of aimeos/aimeos** - a full-featured Laravel e-commerce platform - with a custom Docker setup modified for easy deployment on Dokploy. Aimeos is an ultra-fast, cloud-native, API-first e-commerce platform supporting multi-vendor marketplaces, multi-channel operations, and SaaS deployments.

**Key Architecture:**
- Laravel 12 as the foundation framework
- Aimeos package (`aimeos/aimeos-laravel`) provides the e-commerce layer
- Laravel Breeze handles authentication UI
- Tailwind CSS + Vite for frontend assets
- Supports three deployment modes: single shop, multi-locale, multi-shop (SaaS/marketplace)

## Development Commands

### Backend (PHP/Laravel)

```bash
# Install PHP dependencies
composer install

# Run database migrations
php artisan migrate

# Setup Aimeos tables and data
php artisan aimeos:setup

# Start development server
php artisan serve
# Access at http://127.0.0.1:8000
# Admin backend at http://127.0.0.1:8000/admin

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize for production (run in containers)
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run Aimeos background jobs (order processing, emails)
php artisan aimeos:jobs
```

### Frontend (JS/CSS)

```bash
# Install NPM dependencies
npm install

# Run Vite development server with HMR
npm run dev

# Build for production
npm run build
```

### Testing

```bash
# Run all tests
./vendor/bin/phpunit

# Run specific test suite
./vendor/bin/phpunit --testsuite=Feature
./vendor/bin/phpunit --testsuite=Unit

# Run a single test file
./vendor/bin/phpunit tests/Feature/Auth/AuthenticationTest.php

# Code style fixes (PSR-12)
./vendor/bin/pint
```

### Docker Deployment

```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down

# Rebuild after changes
docker-compose up -d --build
```

## Architecture & Code Structure

### Multi-Tenancy Configuration

The application supports three operational modes configured via `.env`:

1. **Single Shop Mode** (default): Standard e-commerce site
2. **Multi-Locale Mode** (`SHOP_MULTILOCALE=true`): Language-based routing with locale prefix
3. **Multi-Shop Mode** (`SHOP_MULTISHOP=true`): SaaS marketplace with vendor isolation and site-based routing
4. **Vendor Registration** (`SHOP_REGISTRATION=true`): Self-service vendor onboarding
5. **Multi-Route Mode** (`SHOP_MULTIROUTE=true`): Top-level URLs for products/pages (performance impact)

These settings dynamically modify route prefixes and middleware in `config/shop.php`.

### Route Architecture

Routes are defined dynamically in `config/shop.php` based on environment variables:

- **Admin Routes**: `/admin/{site}/jqadm` - Backend administration (requires auth)
- **GraphQL API**: `/admin/{site}/graphql` - Admin GraphQL endpoint
- **JSON REST API**: `/jsonapi` - Public REST API (jsonapi.org compliant)
- **Shop Frontend**: `/{locale}/shop` or `/{locale}/{site}/shop` depending on mode
- **Account Pages**: `/{locale}/profile` - User account management (requires auth)

The `{site}` parameter enables multi-tenancy, `{locale}` enables multi-language support.

### Page Component System

Aimeos uses a component-based architecture where pages are composed of reusable components defined in `config/shop.php`:

```php
'page' => [
    'catalog-detail' => [
        'locale/select', 'basket/mini', 'catalog/tree',
        'catalog/search', 'catalog/stage', 'catalog/detail'
    ],
    // Each page assembles multiple components
]
```

Components are rendered in order and handle specific UI/functionality aspects.

### Filesystem Abstraction

Aimeos uses Laravel's filesystem abstraction with multiple disks for different purposes:

- `fs-media`: Product media (public/aimeos - volume mounted in Docker)
- `fs-import`: Data imports
- `fs-export`: Data exports
- `fs-secure`: Protected files (downloads, invoices)
- `fs-admin`: Admin uploads

Configuration in `config/shop.php` allows switching between local, S3, etc.

### Custom Extensions

Local packages can be added to `/packages/*` directory. They are auto-discovered via composer's PSR-4 autoloading with path repository configured in `composer.json`.

## Docker Infrastructure

### Dockerfile Architecture

The repository uses a **multi-stage build** for optimized production images:

**Build Stage:**
- Uses `composer:2` to install PHP dependencies
- Runs `composer install --no-dev --optimize-autoloader` for production
- No dev dependencies included in final image

**Production Stage:**
- Base: `php:8.2-fpm-alpine`
- Installs: Nginx, Supervisor, MySQL client
- PHP Extensions: pdo_mysql, gd, zip, intl, mbstring, bcmath, opcache
- Copies configuration from `/docker` directory (nginx, php, supervisor)
- Document root: `/var/www/html/public`
- Entrypoint: `/docker/start.sh`
- Exposes port 80

### Docker Services

- **app**: PHP-FPM + Nginx + Supervisor (port 80)
- **db**: MySQL 8.0 (port 3306)
- **redis**: Redis 7 Alpine (for caching/sessions)

### Container Startup Sequence (`docker/start.sh`)

1. Wait for database availability
2. Run `php artisan migrate --force`
3. Run `php artisan aimeos:setup` (creates Aimeos tables)
4. Cache optimization (config, routes, views)
5. Start Supervisor (manages php-fpm, nginx, aimeos-jobs)

### Supervisor Processes

Defined in `docker/supervisor/supervisord.conf`:

- `php-fpm`: PHP FastCGI Process Manager
- `nginx`: Web server
- `aimeos-jobs`: Background job processing (critical for order emails, payments, subscriptions)

### Persistent Volumes

- `storage`: Laravel storage directory (logs, framework cache, sessions)
- `aimeos_files`: Public media files (product images, downloads)
- `mysql_data`: Database persistence
- `redis_data`: Redis persistence

## Configuration Management

### Environment Variables

Key `.env` variables affecting application behavior:

```bash
# Deployment mode
SHOP_MULTILOCALE=false    # Enable locale-based routing
SHOP_MULTISHOP=false      # Enable multi-vendor SaaS mode
SHOP_REGISTRATION=false   # Allow vendor self-registration
SHOP_PERMISSION=admin     # Default permission level for new vendors

# Performance
APP_ENV=production        # Set to production in containers
APP_DEBUG=false          # Disable debug mode in production

# Caching (set in shop.php)
apc_enabled=false        # Enable APCu for maximum performance
apc_prefix=aimeos:      # Cache key prefix
```

### Admin Access

Users with roles defined in `config/shop.php` (`'roles' => ['admin', 'editor']`) can access the admin backend at `/admin`. Gates are checked in middleware.

## API Architecture

### JSON REST API

- Endpoint: `/jsonapi`
- Compliant with jsonapi.org specification
- Middleware: `['web', 'api']`
- Authentication: Laravel Sanctum (configured)

### GraphQL API

- Endpoint: `/admin/{site}/graphql`
- For admin operations
- Requires authentication
- Middleware: `['web', 'auth']`

## Performance Considerations

### Production Optimizations

Always run these in production/containers:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### OPcache Configuration

Enabled in `docker/php/opcache.ini`:
- Memory: 128MB
- File cache enabled
- CLI OPcache enabled for artisan commands

### Multi-Route Performance Warning

Enabling `SHOP_MULTIROUTE=true` adds database queries to every request for URL resolution. Only enable if top-level product/category URLs are required.

## Testing Strategy

Tests located in `tests/` directory:

- **Unit Tests**: Business logic, utilities (`tests/Unit/`)
- **Feature Tests**: HTTP routes, authentication flows (`tests/Feature/`)

Laravel Breeze provides comprehensive auth tests covering registration, login, password reset, email verification.

Test environment uses in-memory/mock drivers (array cache, array mail, sync queue) for speed.

## Common Workflows

### Adding a New Feature

1. Check if Aimeos already provides similar functionality (consult [Aimeos docs](https://aimeos.org/docs/latest/laravel))
2. For shop components: extend or add to `config/shop.php` page definitions
3. For admin features: follow Aimeos JQAdm component structure
4. For custom packages: create in `/packages/*` with proper PSR-4 autoloading

### Database Changes

Aimeos manages its own schema via `php artisan aimeos:setup`. For custom tables:

1. Create Laravel migration in `database/migrations/`
2. Run `php artisan migrate`
3. Keep separate from Aimeos tables

### Deployment to Dokploy

1. Create the missing Dockerfile based on infrastructure in `/docker`
2. Ensure `.env` has production values (APP_ENV, APP_DEBUG, database credentials)
3. Set required environment variables in Dokploy
4. Deploy with `docker-compose.yml`
5. Container will auto-run migrations and Aimeos setup via `/docker/start.sh`

## Important Notes

- **Never commit `.env`** - contains sensitive credentials
- **Aimeos tables are managed by Aimeos** - don't create migrations for them
- **Background jobs must run** - ensure `aimeos-jobs` supervisor process is running for order processing
- **Public media requires persistence** - ensure `public/aimeos` volume is properly mounted
- **Multi-shop mode changes URLs** - test routing when switching modes
- The `aimeos/aimeos-laravel` package is set to `dev-master` - pin to stable version for production

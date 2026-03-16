# Docker Guide

## Quick Start with Docker

```bash
# Clone the repository
git clone <repository-url>
cd aimeos

# Copy environment file (optional - will be auto-generated if missing)
cp .env.example .env

# Edit .env with your database credentials and settings
# Required: APP_KEY, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_ROOT_PASSWORD
# Optional: SHOP_MULTILOCALE, SHOP_MULTISHOP, SHOP_REGISTRATION, etc.

# Build and start containers
docker compose up -d

# The application will be automatically set up on first run
# Access the application at http://localhost
```

Access the application:
- Frontend: http://localhost
- Admin: http://localhost/admin
- Health check: http://localhost/up

## Deployment to Dokploy

1. Configure Dokploy with git repository URL
2. Set environment variables in Dokploy dashboard:
   - `APP_KEY`: Laravel application key
   - `DB_DATABASE`: Database name
   - `DB_USERNAME`: Database user
   - `DB_PASSWORD`: Database password
   - `DB_ROOT_PASSWORD`: MySQL root password
   - `REDIS_PASSWORD`: Redis password (optional)
   - `MAIL_*`: Email configuration (optional)
   - `SHOP_MULTILOCALE`: Enable multi-locale mode (optional)
   - `SHOP_MULTISHOP`: Enable multi-shop mode (optional)
   - `SHOP_REGISTRATION`: Enable vendor registration (optional)
3. Configure persistent volumes:
   - `mysql_data`: MySQL data directory
   - `storage`: Laravel storage (logs, cache, sessions)
   - `aimeos_files`: Product images and uploads
   - `redis_data`: Redis data directory
4. Deploy application
5. The application will auto-configure on first startup

## Docker Architecture

### Base Image
- **serversideup/php:8.4-fpm-nginx**: Optimized PHP 8.4 with Nginx and PHP-FPM
- Includes Node.js 22 for frontend asset building
- Pre-installed PHP extensions: gd, intl, bcmath, zip, exif, pcntl, pdo_mysql, redis

### Services

- **app**: PHP-FPM + Nginx web server (port 80:8080)
  - Auto-generates `.env` from `.env.example` using environment variables
  - Runs Aimeos setup automatically on first startup
  - Includes health check endpoint at `/up`
- **db**: MySQL 8.0 database (port 3306)
  - Includes health check for connection monitoring
- **redis**: Redis 7 Alpine for caching and sessions (port 6379)
  - Append-only file persistence enabled

### Entrypoint Scripts

The container runs initialization scripts in order:

1. **10-generate-env.sh**: Generates `.env` file from `.env.example` template, substituting environment variables
2. **20-aimeos-setup.sh**: Publishes vendor assets and runs `php artisan aimeos:setup`

### Health Checks

All services include health checks:
- **App**: HTTP GET request to `/up` endpoint
- **Database**: `mysqladmin ping` command
- **Redis**: `redis-cli ping` command

### Volumes

Critical persistent volumes for data retention:
- `mysql_data`: MySQL database files
- `storage`: Laravel framework storage (logs, cache, sessions)
- `aimeos_files`: Product images, downloads, and user uploads
- `redis_data`: Redis persistence files

### Environment Variables

Key configuration options:

```bash
# Application
APP_NAME=Aimeos
APP_ENV=production
APP_KEY=your-app-key
APP_DEBUG=false
APP_URL=http://localhost

# Shop Configuration
SHOP_MULTILOCALE=false    # Enable multi-language routing
SHOP_MULTISHOP=false      # Enable multi-vendor marketplace
SHOP_REGISTRATION=false   # Allow vendor self-registration
SHOP_PERMISSION=admin     # Default permission level

# Database
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=aimeos
DB_USERNAME=aimeos
DB_PASSWORD=secret

# Cache & Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=sync
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=null

# Email (optional)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=null
```

## Development Workflow

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Access container shell
docker-compose exec app bash

# Run artisan commands
docker-compose exec app php artisan <command>

# Stop services
docker-compose down
```

## Testing

```bash
# Run tests in container
docker-compose exec app ./vendor/bin/phpunit

# Run specific test suite
docker-compose exec app ./vendor/bin/phpunit --testsuite=Feature

# Code style checking
docker-compose exec app ./vendor/bin/pint
```

## Important Notes

### Automatic Setup
- The container automatically generates `.env` and runs Aimeos setup on first startup
- No manual migration or setup commands needed for initial deployment
- Demo data can be loaded by setting environment variable or running manually

### Background Jobs
- Aimeos job scheduler runs via Supervisor for order processing and notifications
- Jobs are configured to run automatically in the container

### Security
- Generate strong `APP_KEY` for production
- Use secure passwords for database and Redis
- Configure proper firewall rules for exposed ports

### Performance
- Redis caching is enabled by default
- OPcache is configured in the base image
- Static assets are built during container build

### Troubleshooting
- Check container logs: `docker-compose logs app`
- Verify environment variables are set correctly
- Ensure volumes have proper permissions
- Health checks will indicate service status

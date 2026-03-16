FROM serversideup/php:8.4-fpm-nginx

USER root

# Install Node.js 22 for asset building
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install additional PHP extensions (not pre-installed in base)
RUN install-php-extensions \
    gd \
    intl \
    bcmath \
    zip \
    exif \
    pcntl \
    pdo_mysql \
    redis

WORKDIR /var/www/html

# Copy dependency files first for better layer caching
COPY --chown=www-data:www-data composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copy application files
COPY --chown=www-data:www-data . .

# Pre-create .env so it always exists before entrypoint scripts run
RUN cp .env.example .env && chown www-data:www-data .env

# Run post-install scripts (generates autoload, runs package discovery)
RUN composer run-script post-autoload-dump 2>/dev/null || true

# Build frontend assets and remove dev dependencies
RUN npm install && npm run build && rm -rf node_modules

# Copy custom startup scripts
COPY --chown=root:root docker/entrypoint.d/ /etc/entrypoint.d/
RUN chmod +x /etc/entrypoint.d/*.sh

USER www-data

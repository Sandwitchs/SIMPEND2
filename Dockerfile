FROM php:8.1-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    zip \
    unzip \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev

# Configure and install PHP extensions (pdo, pdo_mysql, gd)
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql gd

# Install Composer (latest)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application source code
COPY . .

# Install PHP dependencies (no dev packages, optimized autoloader)
RUN composer install --no-dev --optimize-autoloader

# Expose the web server port (Railway will proxy HTTP traffic)
EXPOSE 80

# Start PHP-FPM and Nginx in the same container
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'" ]

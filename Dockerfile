FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

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

# Enable Apache mod_rewrite (required for Laravel routing)
RUN a2enmod rewrite

# Expose the web server port (Railway will proxy HTTP traffic)
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]

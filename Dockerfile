FROM php:8.4-fpm

# Dependências de sistema: bibliotecas para as extensões PHP + Tesseract
# OCR (com idioma português) + Ghostscript (conversão de PDF em imagem).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libicu-dev \
        libonig-dev \
        unzip \
        git \
        tesseract-ocr \
        tesseract-ocr-por \
        ghostscript \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        mbstring \
        zip \
        bcmath \
        gd \
        intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer (para rodar `composer install` manualmente após subir o
# container — o código chega por bind mount, não é copiado aqui).
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Ajustes de php.ini pensados para os documentos maiores que já vimos
# dar problema (PDFs grandes na extração/OCR).
RUN { \
        echo 'memory_limit = 1024M'; \
        echo 'upload_max_filesize = 50M'; \
        echo 'post_max_size = 50M'; \
        echo 'max_execution_time = 300'; \
    } > /usr/local/etc/php/conf.d/auditoria.ini

WORKDIR /var/www/html

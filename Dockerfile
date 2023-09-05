FROM node:18 as build

WORKDIR /app
COPY . .
RUN npm install && \
    npm run build

FROM webdevops/php-nginx:8.1-alpine
ENV WEB_DOCUMENT_ROOT=/app/public

WORKDIR /app
COPY --from=build /app .

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN php artisan optimize && \
    php please cache:clear && \
    php please stache:refresh && \
    php artisan config:clear && \
    php artisan view:clear

# Ensure all of our files are owned by the same user and group.
RUN chown -R application:application .

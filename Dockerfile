FROM node:18 as build

WORKDIR /app
COPY . .
RUN npm install && \
    npm run build

FROM webdevops/php-nginx:8.1-alpine
ENV WEB_DOCUMENT_ROOT=/app/public

WORKDIR /app
COPY --from=build /app .

RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    php artisan optimize && \
    php please cache:clear

# Ensure all of our files are owned by the same user and group.
RUN chown -R application:application .

# Base stage
FROM alpine AS base
WORKDIR /app
COPY . .

# PHP target
FROM php:8.2-fpm AS php
COPY --from=base /app /var/www/html

# Nginx target
FROM nginx:latest AS nginx
COPY --from=base /app /usr/share/nginx/html

# Node target
FROM node:18 AS node
COPY --from=base /app /app
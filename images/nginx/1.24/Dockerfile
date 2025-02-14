# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/compose/compose-file/#target


ARG NGINX_VERSION=1.24

########################################################################################

FROM nginx:${NGINX_VERSION}-alpine AS sylius_nginx

WORKDIR /srv/sylius

COPY etc/default.conf /etc/nginx/conf.d/

VOLUME /srv/sylius/public
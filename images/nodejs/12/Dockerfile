# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/compose/compose-file/#target

ARG NODE_VERSION=12
ARG ALPINE_VERSION=3.14

########################################################################################

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS sylius_nodejs

WORKDIR /srv/sylius

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		g++ \
		gcc \
		make \
        python2 \
	;

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["yarn", "build"]
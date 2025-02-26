ARG MYSQL_VERSION=8.0

FROM mysql:${MYSQL_VERSION} AS sylius_mysql

# Copy custom MySQL entrypoint script
COPY etc/mysql-entrypoint.sh /usr/local/bin/mysql-entrypoint.sh
RUN chmod +x /usr/local/bin/mysql-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/mysql-entrypoint.sh"]

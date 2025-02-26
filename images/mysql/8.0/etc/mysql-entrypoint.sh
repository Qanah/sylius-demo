#!/bin/bash
set -e

# Generate a unique server ID based on hostname
SERVER_ID=$(hostname | awk -F'-' '{print $NF}')
if ! [[ "$SERVER_ID" =~ ^[0-9]+$ ]]; then
  SERVER_ID=$(( RANDOM % 10000 + 1 ))  # Fallback random ID
fi

echo "Starting MySQL with server-id=$SERVER_ID"

# Wait for MySQL to be ready
while ! mysqladmin ping -h localhost --silent; do
  echo "Waiting for MySQL to start..."
  sleep 2
done

# Discover MySQL nodes in the Swarm network
echo "Discovering MySQL nodes..."
SEEDS=""
for NODE in $(getent hosts tasks.mysql-node | awk '{print $1}'); do
  if [ "$SEEDS" == "" ]; then
    SEEDS="$NODE:33061"
  else
    SEEDS="$SEEDS,$NODE:33061"
  fi
done
echo "Group Replication Seeds: $SEEDS"

# Get the network subnet dynamically for IP whitelist
IP_WHITELIST="$(ip -o -f inet addr show eth0 | awk '{print $4}' | cut -d/ -f1)/16"

echo "Setting group_replication_ip_whitelist to $IP_WHITELIST"

# If first node, bootstrap Group Replication
if [ "$SERVER_ID" -eq 1 ]; then
  echo "Bootstrapping Group Replication..."
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
SET SQL_LOG_BIN=0;
CREATE USER IF NOT EXISTS '$MYSQL_REPLICATION_USER'@'%' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_REPLICATION_PASSWORD';
GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPLICATION_USER'@'%';
FLUSH PRIVILEGES;
CHANGE MASTER TO MASTER_USER='$MYSQL_REPLICATION_USER', MASTER_PASSWORD='$MYSQL_REPLICATION_PASSWORD' FOR CHANNEL 'group_replication_recovery';
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
EOF
fi

# Other nodes join automatically
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
CHANGE MASTER TO MASTER_USER='$MYSQL_REPLICATION_USER', MASTER_PASSWORD='$MYSQL_REPLICATION_PASSWORD' FOR CHANNEL 'group_replication_recovery';
START GROUP_REPLICATION;
EOF

# Start MySQL with dynamic replication settings
exec mysqld \
  --server-id=$SERVER_ID \
  --log-bin=mysql-bin \
  --gtid-mode=ON \
  --enforce-gtid-consistency=ON \
  --log-slave-updates=ON \
  --binlog-format=ROW \
  --plugin-load=group_replication.so \
  --group-replication=ON \
  --group-replication-local-address="$(hostname):33061" \
  --group-replication-group-seeds="$SEEDS" \
  --group-replication-group-name="${REPLICATION_GROUP_NAME:-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}" \
  --group-replication-ip-whitelist="$IP_WHITELIST" \
  --group-replication-start-on-boot=ON
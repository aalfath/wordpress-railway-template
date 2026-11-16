#!/bin/bash
# Runs before the official entrypoint: Apache port, PHP limits, wp-content ownership.
set -euo pipefail

# Listen on Railway's PORT (80 when unset).
PORT="${PORT:-80}"
sed -ri "s/^Listen [0-9]+$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# PHP limits. Override with PHP_UPLOAD_LIMIT / PHP_MEMORY_LIMIT if needed.
cat > /usr/local/etc/php/conf.d/zz-railway.ini <<INI
upload_max_filesize = ${PHP_UPLOAD_LIMIT:-128M}
post_max_size = ${PHP_UPLOAD_LIMIT:-128M}
memory_limit = ${PHP_MEMORY_LIMIT:-256M}
max_execution_time = 300
max_input_vars = 3000
INI

# A fresh Railway volume is owned by root; WordPress (www-data) must write to it.
mkdir -p /var/www/html/wp-content
if [ "$(stat -c '%U' /var/www/html/wp-content)" != "www-data" ]; then
  chown www-data:www-data /var/www/html/wp-content
fi

# Core is updated through this template's repo, not from wp-admin (core files
# are not on the volume, so an in-place core update would be lost on redeploy).
export WORDPRESS_CONFIG_EXTRA="${WORDPRESS_CONFIG_EXTRA:-}
defined('WP_AUTO_UPDATE_CORE') || define('WP_AUTO_UPDATE_CORE', false);"

# The official entrypoint copies core into /var/www/html and writes wp-config.php
# from the WORDPRESS_* variables, then runs apache2-railway.
exec docker-entrypoint.sh "$@"

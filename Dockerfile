# WordPress for Railway: the official image, pinned by version and digest,
# plus a small wrapper (start scripts, PHP limits, a /healthz path, WP-CLI).
FROM wordpress:7.1.4-php8.3-apache@sha256:074f9ef5429025dab76a4242f5b796f64ae76a49dd19b6708ad29e1893a8d383

# WP-CLI, pinned and checksum-verified. Used once, to install WordPress on first boot.
ARG WP_CLI_VERSION=2.12.0
ARG WP_CLI_SHA512=be928f6b8ca1e8dfb9d2f4b75a13aa4aee0896f8a9a0a1c45cd5d2c98605e6172e6d014dda2e27f88c98befc16c040cbb2bd1bfa121510ea5cdf5f6a30fe8832
RUN curl -fsSL -o /usr/local/bin/wp "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" \
 && echo "${WP_CLI_SHA512}  /usr/local/bin/wp" | sha512sum -c - \
 && chmod +x /usr/local/bin/wp

COPY healthz.conf /etc/apache2/conf-available/healthz.conf
COPY healthz.txt /usr/local/share/railway/healthz.txt
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY apache2-railway /usr/local/bin/apache2-railway
RUN a2enconf healthz && chmod +x /usr/local/bin/railway-entrypoint.sh /usr/local/bin/apache2-railway

# Only wp-content is persistent (Railway volume). WordPress core comes from the
# image, so a template update brings a new core version.
ENTRYPOINT ["railway-entrypoint.sh"]
CMD ["apache2-railway"]

# Changelog

## Unreleased

- README: Deploy on Railway button linking to the published template, code wordpress-5. No change to the deployed app.

## 7.1.4 (2026-11-16)

- First release: WordPress 7.1.4 (`wordpress:7.1.4-php8.3-apache@sha256:074f9ef5429025dab76a4242f5b796f64ae76a49dd19b6708ad29e1893a8d383`) with Railway MySQL.
- Installs WordPress on first boot with WP-CLI 2.12.0, `wp-content` on a volume, `/healthz` health path, Apache on `PORT`, PHP upload limit 128 MB.
- Keeps only Apache's prefork MPM at start, which avoids `AH00534: More than one MPM loaded` on Railway builds.

# WordPress on Railway

A Railway template for [WordPress](https://wordpress.org/) 7.1.4, built from this repo.

## What it deploys

| Service | Source | Data |
|---|---|---|
| **WordPress** | This repo's `Dockerfile`: the official `wordpress:7.1.4-php8.3-apache` image, pinned by digest, plus a small wrapper | `wp-content` (themes, plugins, uploads) on a volume |
| **MySQL** | Railway's MySQL database | `/var/lib/mysql` on a volume |

The wrapper:

- installs WordPress on first boot with [WP-CLI](https://wp-cli.org/) (pinned, checksum-verified), so the public install wizard is never exposed. Log in at `/wp-admin` with `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD` from the WordPress service's variables;
- makes Apache listen on Railway's `PORT` and serves a `/healthz` path for Railway's health check;
- raises PHP limits: 128 MB uploads, 256 MB memory, 300 s execution time (override with `PHP_UPLOAD_LIMIT` and `PHP_MEMORY_LIMIT`);
- makes the volume writable by WordPress and switches off automatic core updates (core comes from the image, see below).

Railway terminates TLS. The official image already trusts `X-Forwarded-Proto`, so WordPress serves HTTPS links with no redirect loop.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `WP_ADMIN_EMAIL` | *(you enter it)* | Admin account email |
| `WP_ADMIN_USER` | `admin` | Admin username, used on first boot only |
| `WP_ADMIN_PASSWORD` | generated | Admin password, used on first boot only. Change it in WordPress afterwards if you like |
| `WORDPRESS_DB_*` | references to MySQL | Database connection |
| `WORDPRESS_AUTH_KEY` … `WORDPRESS_NONCE_SALT` | generated | WordPress keys and salts. Changing them logs everyone out |
| `PORT` | `80` | Port Apache listens on |

Optional, add them yourself: `WP_SITE_TITLE` (first boot only), `WP_SITE_URL` (first boot only, defaults to `https://<Railway domain>`), `WORDPRESS_CONFIG_EXTRA` (extra PHP for `wp-config.php`), `PHP_UPLOAD_LIMIT`, `PHP_MEMORY_LIMIT`.

**Custom domain:** add it in Railway, then change *WordPress Address* and *Site Address* under Settings → General.

**Email:** the container can't send mail by itself. Install an SMTP plugin (for example WP Mail SMTP) for password resets and notifications.

## Updates

WordPress core lives in the image and only `wp-content` is on the volume. New WordPress versions reach you as a template update: when this repo's `main` changes, Railway shows "update available" on your project, and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first. Don't update core from Dashboard → Updates: that change isn't on the volume and is lost on the next redeploy. Plugins and themes update from wp-admin as usual.

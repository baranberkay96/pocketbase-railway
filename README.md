# Deploy and Host PocketBase with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pocketbase-backend-auth-realtime-db-file?referralCode=20H68q)

PocketBase is an open-source backend in a single Go binary: an embedded SQLite database with realtime subscriptions, user authentication (email, OAuth2, OTP), file storage and an admin dashboard, all behind one REST API. This template runs the official release on a Railway volume with the superuser created for you.

## About Hosting PocketBase

PocketBase keeps everything in one data directory (`pb_data`): the SQLite databases, uploaded files and backups. Hosting it well means a persistent volume, a public HTTPS domain, an admin account that exists before anyone can reach the dashboard, and settings that fit a proxy in front. This community template builds the official PocketBase release (checksum-verified) on a pinned Alpine image, mounts a Railway volume at `/pb_data`, creates the superuser from generated variables before the port opens, encrypts stored SMTP/S3 secrets, and on first start sets the app URL to your Railway domain, trusts Railway's client-IP header, turns on PocketBase's rate limits and schedules a daily backup.

## Common Use Cases

- Backend for web and mobile apps: auth, database and file uploads without writing a server
- Realtime apps (chat, dashboards, collaborative lists) using PocketBase's subscriptions
- Prototypes and internal tools with an admin UI for the data
- A small Go/JS-extendable backend: custom routes, hooks and cron jobs in `pb_hooks`

## Dependencies for PocketBase Hosting

- One service built from the official PocketBase release (no external database)
- A Railway volume at `/pb_data`
- Optional: an email provider (SMTP) for verification and password-reset mails; S3-compatible storage (for example a Railway Bucket) for files or backups

### Deployment Dependencies

- [PocketBase documentation](https://pocketbase.io/docs/)
- [PocketBase releases](https://github.com/pocketbase/pocketbase/releases)
- [Going to production](https://pocketbase.io/docs/going-to-production/)
- [JavaScript hooks and migrations](https://pocketbase.io/docs/js-overview/)

### Implementation Details

| Service | What runs inside | Volume | Port |
|---|---|---|---|
| PocketBase | PocketBase 0.40.6 (`pocketbase serve`) | `/pb_data` (SQLite, uploads, backups) | 8080, public domain |

**First login**

1. Open `https://{your-domain}/_/`.
2. Log in with `PB_ADMIN_EMAIL` (default `admin@example.com`) and `PB_ADMIN_PASSWORD` (generated; see the service's Variables tab).
3. Create collections, then use the REST API at `https://{your-domain}/api/` or the official JS/Dart SDKs.

The superuser is saved from these two variables at every start, so the variable is the source of truth: to change the password, change `PB_ADMIN_PASSWORD` and redeploy (a password changed only in the dashboard is reset on the next start). A password shorter than 10 characters is ignored with a warning in the log, and the existing password stays. Changing `PB_ADMIN_EMAIL` adds a second superuser; delete the old one in the dashboard.

**Defaults set on the first start** (a migration in `pb_migrations`; change them later under Settings):

- Application URL `https://{your-domain}` (used in email links) and name from `PB_APP_NAME`
- Trusted proxy header `X-Real-IP`, so logs and rate limits see real client addresses
- PocketBase's built-in rate limits on
- Daily backup at 03:00 UTC into `pb_data/backups`, 7 kept (they count toward the volume size; point backups at S3 under Settings, Backups to keep them off the volume)

**Email and files**

Configure SMTP under Settings, Mail settings. Railway allows outbound SMTP only on the Pro plan; on other plans, send mail from a JS hook through an HTTP email API (Resend, Postmark, SendGrid) with `$http.send`. Uploaded files are stored on the volume by default; for large file volumes, enable S3 storage under Settings, Files storage (a Railway Bucket works as S3).

**Extending**

Use **Eject** in the service settings to get your own copy of the repo, then add JavaScript hooks to `services/pocketbase/pb_hooks/*.pb.js` and migrations to `services/pocketbase/pb_migrations/`. Static files in `/pb/pb_public` are served at the root.

**Scaling and upgrades**

PocketBase is one process with SQLite: run one replica and scale it vertically. It handles thousands of concurrent realtime connections on modest RAM. To upgrade, change `PB_VERSION` and `PB_SHA256` in `services/pocketbase/Dockerfile` (from the release's `checksums.txt`) after reading the release notes, and download a backup first. PocketBase is still before 1.0, so upgrades can contain breaking changes.

**Resources**

Measured on Railway: about 20 MB RAM idle (16–22 MB), near 0 vCPU. Trial plan is enough for small apps; cost is roughly $0.5–2/month plus the volume. Image thumbnails of very large pictures can use a lot of RAM (PocketBase limits the source size).

**Security**

`PB_ENCRYPTION_KEY` (generated, 32 characters) encrypts SMTP and S3 secrets in the database. Do not change it after the first start, or those settings can no longer be read. Superuser IP allow-lists and MFA are available under Settings.

### Why Deploy PocketBase on Railway?

PocketBase needs exactly what Railway gives a single service: a persistent volume, HTTPS on a public domain and automatic restarts. You get a working backend with an admin login in a minute, and it costs about as little as a backend can. This is a community template, not affiliated with PocketBase.

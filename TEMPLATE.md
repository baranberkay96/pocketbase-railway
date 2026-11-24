# TEMPLATE: PocketBase Backend (Auth, Realtime DB, Files)

Composer spec. `template.json` is the machine-readable copy.

## Service

| Field | Value |
|---|---|
| Name | PocketBase |
| Source | repo `baranberkay96/pocketbase-railway`, root `/services/pocketbase` |
| Base | `alpine:3.24.4@sha256:f59abe65…` (2026-11-24) |
| PocketBase | v0.40.6 `pocketbase_0.40.6_linux_amd64.zip`, SHA-256 `0e1f6091…` from the release's checksums.txt (released 2026-10-23, latest) |
| Public domain | yes, target port 8080 |
| Healthcheck | `/api/health`, 300 s |
| Restart | ALWAYS |
| Volume | `/pb_data` (`--dir`) |

Variables: `PB_ADMIN_EMAIL` (admin@example.com), `PB_ADMIN_PASSWORD` (secret 24), `PB_ENCRYPTION_KEY` (secret 32), `PB_APP_NAME` (PocketBase), `PORT` (8080), `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` (10). No required inputs.

## Design

- `railway-start` (sh): validates PORT, email (invalid → default), password length 10–71; `pocketbase superuser upsert` before `serve` (STANDARD 8.37: no installer link ever needed). Invalid password → no change to an existing superuser, `superuser create` with a random password on a fresh volume, log explains the fix (8.29). `--encryptionEnv` only with a 32-char key (else warning, unencrypted). `exec pocketbase serve --http=[::]:$PORT`.
- `pb_migrations/1764000000_railway_defaults.js` (runs once): appName, appURL `https://$RAILWAY_PUBLIC_DOMAIN`, trusted proxy header `X-Real-IP`, rate limits on, backups cron `0 3 * * *` keep 7.
- `pb_hooks/` empty, for user hooks; `/pb/pb_public` for static files.

## Improvements over market templates

- Market templates (FarazPatankar, botwayorg, Shinyduo repos) download unpinned or old releases without checksums, have no healthcheck, and either leave the first-superuser installer to the deployer or ship a fixed default password in the template. This one pins the latest release with SHA-256, pre-creates the superuser from generated secrets, encrypts settings, configures the proxy header and rate limits, schedules backups, and never crash-loops on a bad variable.

## Resources

| Service | Idle RAM | Typical RAM | CPU |
|---|---|---|---|
| PocketBase | ≈20 MB (measured) | 50–300 MB (more for thumbnails of large images) | ≈0 idle |

Estimated cost: $0.5–2/month + volume ($0.15/GB-month). Minimum plan: Trial.

## Verification checklist

- `/api/health` 200; `/_/` loads; superuser auth with the generated password returns a token.
- Create a collection and a record via the API; record survives a redeploy.
- Settings show appURL = Railway domain, trusted proxy `X-Real-IP`, rate limits on, backups cron.
- `PB_ADMIN_PASSWORD=abc` → deploy SUCCESS, old password still works, warning in the log.
- Manual backup via API works and lands in `pb_data/backups`.

## Open questions

- PocketBase announced that future releases may be published outside GitHub (ganigeorgiev.com); the pinned v0.40.6 GitHub asset stays downloadable. Re-check the release source when upgrading.

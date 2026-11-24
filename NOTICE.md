# NOTICE: PocketBase template

This is a community template. It is not made, endorsed or supported by PocketBase or Railway.

## Components

| Component | Source | License | How it is used |
|---|---|---|---|
| PocketBase 0.40.6 (`pocketbase_0.40.6_linux_amd64.zip`, SHA-256 `0e1f609158ed945f809f8a02ae012aa0427129c66ebb63c1aee76f2c0309373f`) | https://github.com/pocketbase/pocketbase | MIT (Copyright (c) 2022 - present, Gani Georgiev) | Official release binary, unmodified, in `/usr/local/bin/pocketbase` |
| Alpine Linux 3.24.4 (`alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf`), ca-certificates, tzdata | https://hub.docker.com/_/alpine | Each package's own license | Base image |

## Files written for this template

`services/pocketbase/Dockerfile`, `services/pocketbase/railway-start.sh`, `services/pocketbase/pb_migrations/1764000000_railway_defaults.js` and the documentation were written for this template and are offered under the MIT License.

## Upstream files checked

- pocketbase v0.40.6 release notes and `checksums.txt`; `cmd/superuser.go` (`superuser upsert|create`, email validation); `core/settings_model.go` (field names `meta.appURL`, `trustedProxy.headers`, `rateLimits.enabled`, `backups.cron`, `backups.cronMaxKeep`).
- pocketbase/site docs: JS migrations ("Initialize default application settings"), going to production.
- The migration was run locally against the official v0.40.6 binary before deploying.

## Market templates

The three PocketBase templates on the Railway marketplace (`FarazPatankar/pocketbase`, `botwayorg/pocketbase`, `Shinyduo/pocketbase-railway`) were reviewed for features only. No files or text were copied.

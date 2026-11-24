# syntax=docker/dockerfile:1
#
# PocketBase 0.40.6 for Railway.
#
# Base: alpine 3.24.4 (multi-arch index digest, checked 2026-11-24).
# PocketBase: the official linux_amd64 release zip from GitHub, checked
# against the release's checksums.txt. To upgrade, change PB_VERSION and
# PB_SHA256 together (both from the release page) and redeploy.
FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

ARG PB_VERSION=0.40.6
ARG PB_SHA256=0e1f609158ed945f809f8a02ae012aa0427129c66ebb63c1aee76f2c0309373f

RUN apk add --no-cache ca-certificates tzdata \
 && apk add --no-cache --virtual .fetch curl unzip \
 && curl -fsSL --retry 5 --retry-all-errors -o /tmp/pb.zip \
      "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip" \
 && echo "${PB_SHA256}  /tmp/pb.zip" | sha256sum -c - \
 && unzip -q /tmp/pb.zip pocketbase -d /usr/local/bin \
 && chmod 0755 /usr/local/bin/pocketbase \
 && rm /tmp/pb.zip \
 && apk del .fetch \
 && mkdir -p /pb/pb_public /pb_data

# Migrations and JS hooks shipped with this template (see README). Your own
# go next to them after you eject the repo.
COPY pb_migrations /pb/pb_migrations
COPY pb_hooks /pb/pb_hooks
COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/railway-start"]

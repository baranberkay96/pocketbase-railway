/// <reference path="../pb_data/types.d.ts" />

// Railway defaults, applied once on the first start (PocketBase records the
// migration in _migrations). Everything here can be changed later in the
// dashboard under Settings; this file never runs again.
migrate((app) => {
  const settings = app.settings()

  const appName = ($os.getenv("PB_APP_NAME") || "").trim()
  if (appName) {
    settings.meta.appName = appName.slice(0, 255)
  }

  // Links in emails (verification, password reset) need the public URL.
  const domain = ($os.getenv("RAILWAY_PUBLIC_DOMAIN") || "").trim()
  if (domain) {
    settings.meta.appURL = "https://" + domain
  }

  // Railway's edge proxy passes the client address in X-Real-IP. Without
  // this, logs and rate limits would see the proxy's address for everyone.
  settings.trustedProxy.headers = ["X-Real-IP"]
  settings.trustedProxy.useLeftmostIP = false

  // Built-in rate limits (per client IP) against brute force and abuse.
  settings.rateLimits.enabled = true

  // Daily backup at 03:00 UTC into pb_data/backups on the volume, 7 kept.
  // Point backups at S3 (for example a Railway Bucket) under Settings, Backups.
  settings.backups.cron = "0 3 * * *"
  settings.backups.cronMaxKeep = 7

  app.save(settings)
}, (app) => {
  // Nothing to undo: settings stay as they are.
})

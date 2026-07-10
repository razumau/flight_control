---
name: verify
description: Run and drive the FlightControl dummy app to verify UI/engine changes end-to-end.
---

# Verifying FlightControl changes in the dummy app

## Ruby / test runner
System Ruby is 2.6 — activate mise first: `eval "$(mise activate bash)"` (project uses Ruby 3.3 via `.ruby-version`). Tests: `bin/rails test` from the repo root.

## Launch the dummy app
```bash
eval "$(mise activate bash)"
cd test/dummy && bin/rails server -p 3999   # background
```
- Dev DB (`test/dummy/db/development_queue.sqlite3`) usually already has seeded finished/failed/blocked/scheduled jobs; reseed with `bin/rails db:seed` if empty.
- UI lives under `/jobs`; tab URLs look like `/jobs/applications/dummy/finished/jobs?server_id=solid_queue`.

## HTTP basic auth
Enabled in development. Credentials come from encrypted credentials: user `dev`, password `secret` (`bin/rails runner 'puts Rails.application.credentials.dig(:flight_control).inspect'`).

**Gotcha:** don't put `dev:secret@` in a browser URL — Turbo throws a `SecurityError` on `history.replaceState` (origin mismatch) which aborts the whole JS module chain, so Stimulus controllers never run and the page silently degrades to server-rendered HTML. Use curl `-u dev:secret` for HTTP checks, and for a browser put a tiny auth-injecting reverse proxy in front (python `http.server` forwarding to 3999 adding the `Authorization` header worked well).

## Browser (for Stimulus/JS behavior)
No Chrome installed; Playwright's cached headless shell works directly:
```bash
BIN=~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-arm64/chrome-headless-shell
TZ=Europe/Warsaw "$BIN" --headless --disable-gpu --timeout=8000 \
  --window-size=1280,700 --screenshot=out.png "http://127.0.0.1:<proxy-port>/jobs/..."
```
- `--dump-dom` instead of `--screenshot` to grep rendered DOM.
- `--timeout=8000` (wall clock) is more reliable than `--virtual-time-budget` for waiting on importmap modules.
- Set `TZ=` to test timezone-dependent JS; `--enable-logging=stderr --v=0` surfaces console errors.

## Useful drives
- Fabricate job states directly: `bin/rails runner` against `SolidQueue::Job` (e.g. `update_columns(finished_at: ...)` to test duration formatting buckets).
- Failed jobs keep `finished_at` nil and get `failed_at` from `failed_execution.created_at`.

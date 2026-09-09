# Changelog

## [Unreleased]

## [2.0.0.beta.3] - 2026-09-09

- Adds back `app/` and `config/` directories to the packaged gem.

## [2.0.0.beta.2] - 2026-09-08

Ported from mission_control-jobs (upstream 1.1.0...1.2.0 and later):

- Adds `enqueued_at` and `scheduled_at` date-range filters, applied natively by Solid Queue.
- Adds a `back_to_main_app_path` setting to point the "Back to main app" link somewhere other than the host's root.
- Routes host-app route helpers used inside the engine through `main_app`, so a base controller redirecting to, say, `new_session_path` keeps working.
- Loads the engine's stylesheets individually so they also work under Propshaft.
- Shows the total of pending jobs on the queues page, and how many times a job has been retried.
- Truncates long job arguments in job lists.
- Orders failed jobs by when they failed rather than by job id.
- Submits the job filters on `change` instead of debouncing keystrokes.
- Swaps only the backtrace when toggling between clean and full.
- Disables Turbo's prefetching of links on hover.
- Redirects to the queues index when showing a queue that no longer exists.
- Shows the raw error when a failed execution's error can't be parsed.
- Fixes `config.active_job.default_page_size` not being applied.
- Fixes the "Expires" tooltip of blocked jobs rendering its markup as text.
- Fixes `JobProxy#duration` when `scheduled_at` isn't set.
- Avoids N+1 count queries when listing Solid Queue queues.

## [2.0.0.beta.1] - 2026-07-20

- Drops support for Resque and Async adapters to focus on Solid Queue.
- Drops support for Rails versions below 8.1.
- Lists newest jobs first on all pages.
- Adds a way to run any Active Job and set parameters for it.
- Shows job run duration in tables with failed and finished jobs.
- Shows Enqueued and Finished as timestamps in addition to relative time.
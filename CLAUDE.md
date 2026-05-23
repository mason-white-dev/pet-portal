# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This is a freshly generated **Rails 8.1** application (`PetPortal`, Ruby 3.3.11) with no domain code yet — no models, controllers, routes, or migrations beyond the framework defaults. The architecture notes below describe the stack the generator wired up, which is what you'll build on top of.

## Commands

```bash
bin/setup              # Install deps, prepare DB, start server (use --skip-server to skip the last step)
bin/dev                # Start the Rails server (just execs `bin/rails server`)
bin/rails console      # REPL
bin/rails db:prepare   # Create + migrate the DB (and load schema if needed)
```

### Tests (Minitest)

```bash
bin/rails test                                   # All tests except system tests
bin/rails test:system                            # System tests (Capybara + Selenium, headless Chrome)
bin/rails test test/models/pet_test.rb           # Single file
bin/rails test test/models/pet_test.rb:42        # Single test by line number
bin/rails db:test:prepare                         # Sync test DB to schema before running (CI does this)
```

### Lint & security (mirrors CI)

```bash
bin/rubocop                # Style (rubocop-rails-omakase); add -a to autocorrect
bin/brakeman --no-pager    # Static security analysis
bin/bundler-audit          # Audit gems for known CVEs
bin/importmap audit        # Audit JS dependencies
```

### Full CI pipeline locally

```bash
bin/ci    # Runs setup, rubocop, all three security scanners, tests, and seed replant
```

`bin/ci` is driven by `config/ci.rb` (using `ActiveSupport::ContinuousIntegration`). The GitHub Actions workflow in `.github/workflows/ci.yml` runs the same steps as separate jobs and additionally runs `test:system`. Keep `config/ci.rb` and the workflow in sync when changing the pipeline.

## Architecture

This app leans entirely on the **Rails 8 "Solid" / no-Node defaults** — several pieces that are normally external services are instead backed by the database. Understanding this is key before adding infrastructure-style dependencies:

- **Database: PostgreSQL, multi-database in production.** Production uses four logical databases off one primary (`config/database.yml`): `primary`, `cache`, `queue`, `cable`. Development/test use a single database. The cache/queue/cable databases have their own migration paths (`db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`) and schemas (`db/cache_schema.rb`, `db/queue_schema.rb`, `db/cable_schema.rb`). The main app schema (`db/schema.rb`) doesn't exist yet — it's generated when you add your first migration.
- **Background jobs: Solid Queue** (DB-backed, no Redis). Jobs subclass `ApplicationJob`. Recurring jobs go in `config/recurring.yml`. In production the worker can run in-process inside Puma (`SOLID_QUEUE_IN_PUMA`) or via `bin/jobs`.
- **Cache: Solid Cache** and **Action Cable: Solid Cable** — both DB-backed. No Redis anywhere by default (the Redis service is commented out in CI).
- **Frontend: Hotwire + import maps, no bundler/Node.** JS is managed by `importmap-rails` — pins live in `config/importmap.rb`, vendored libs in `vendor/javascript`. Stimulus controllers go in `app/javascript/controllers/` and are auto-registered via `app/javascript/controllers/index.js`. Turbo is the default for navigation. Assets are served by **Propshaft** (not Sprockets); there is no asset compilation/build step.
- **Web server: Puma fronted by Thruster** (`bin/thrust`) in production for HTTP caching, compression, and X-Sendfile.
- **Deploy: Kamal** (`config/deploy.yml`, `bin/kamal`) — Docker-based, defined by the root `Dockerfile`. The service/image name is `pet_portal`; the production DB password comes from `PET_PORTAL_DATABASE_PASSWORD`.

## Conventions

- Style is **rubocop-rails-omakase** (see `.rubocop.yml`). House-style overrides go in `.rubocop.yml`; run `bin/rubocop -a` before committing.
- Health check endpoint is `/up` (returns 200 if the app boots cleanly); used by load balancers and Kamal.

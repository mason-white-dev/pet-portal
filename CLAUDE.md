# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. It is **shared, role-agnostic context** — auto-loaded into every session and inherited by the project subagents.

> **Working as a specific role?** This repo defines two personas in `.claude/agents/`:
> - `claude --agent dev` — building the Rails app (see `.claude/agents/dev.md`)
> - `claude --agent pm` — managing the ClickUp issue tracker (see `.claude/agents/pm.md`)
>
> Both inherit everything below.

## Product

**Pet Portal** is a consumer-facing **pet EHR** (electronic health record) — a place for a person to store and manage their pet's records. A user signs up, creates a pet, and keeps helpful information at their fingertips.

- **Pet core:** name, species, breed, sex, date of birth, microchip, neutered, notes, avatar photo.
- **Roadmap (feature areas):**
  - **Care Team** — vet, sitter, groomer, etc. *(in progress on branch `pet-portal-care-team`)*
  - **Vaccines** — given date, expiration, reminders
  - **Medical issues** — conditions tracked over time
  - **Pet memories** — photos and keepsakes

## Status

A working **Rails 8.1** application (`PetPortal`, Ruby 3.3.11). Domain so far:

- **Auth:** Devise (`User`); sign-up has no first/last name.
- **Models:** `User` → `has_many :pets`; `Pet` → `has_many :care_team_members`; `CareTeamMember belongs_to :pet`. `Pet` uses string-backed enums (`sex`, `species`) and the `Avatarable` concern (Active Storage `avatar_image`, stored via **Cloudinary**).
- **UI:** My Pets is the landing page; pet profile page; pet create/edit/delete run through a shared Turbo-Frame modal. `CareTeamMember` has a model, migration, routes (nested under pets), and stub tests — but **no controller or views yet** (see the ClickUp Care Team backlog).
- **APM:** Skylight.
- `db/schema.rb` exists; tables: `users`, `pets`, `care_team_members`, plus Active Storage tables.

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

- **Database: PostgreSQL, multi-database in production.** Production uses four logical databases off one primary (`config/database.yml`): `primary`, `cache`, `queue`, `cable`. Development/test use a single database. The cache/queue/cable databases have their own migration paths (`db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`) and schemas (`db/cache_schema.rb`, `db/queue_schema.rb`, `db/cable_schema.rb`). The main app schema lives in `db/schema.rb`.
- **Background jobs: Solid Queue** (DB-backed, no Redis). Jobs subclass `ApplicationJob`. Recurring jobs go in `config/recurring.yml`. In production the worker can run in-process inside Puma (`SOLID_QUEUE_IN_PUMA`) or via `bin/jobs`.
- **Cache: Solid Cache** and **Action Cable: Solid Cable** — both DB-backed. No Redis anywhere by default (the Redis service is commented out in CI).
- **Frontend: Hotwire + import maps, no bundler/Node.** JS is managed by `importmap-rails` — pins live in `config/importmap.rb`, vendored libs in `vendor/javascript`. Stimulus controllers go in `app/javascript/controllers/` and are auto-registered via `app/javascript/controllers/index.js`. Turbo is the default for navigation. Assets are served by **Propshaft** (not Sprockets); there is no asset compilation/build step.
- **Image storage: Active Storage + Cloudinary.** Pet avatars attach via the `Avatarable` concern.
- **Web server: Puma fronted by Thruster** (`bin/thrust`) in production for HTTP caching, compression, and X-Sendfile.
- **Deploy: Render** (not Kamal). The app is hosted on Render; a `render.yml` blueprint is planned but not in the repo yet. A root `Dockerfile` (image/service name `pet_portal`) exists, and production config (DB connection, secrets) is set via Render environment variables. *(The generator's `config/deploy.yml`/`bin/kamal` may still be present but are not the deploy path.)*

## Conventions

- Style is **rubocop-rails-omakase** (see `.rubocop.yml`). House-style overrides go in `.rubocop.yml`; run `bin/rubocop -a` before committing.
- Health check endpoint is `/up` (returns 200 if the app boots cleanly); used by Render and uptime monitors.
- **Enums are string-backed** (the stored DB value is the literal string, e.g. `"dog"`, `"primary_vet"`), keeping raw column values human-readable.
- CRUD UX runs through a **shared Turbo-Frame modal** (drawer), including styled `confirm_delete` confirmations instead of the browser's native `confirm()`. New features should follow this pattern.

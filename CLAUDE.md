# CLAUDE.md

## Running commands in Docker

Most developers run the portal via Docker. When running Rails commands (rspec, rails runner, rake, etc.), use `docker compose exec app` or `docker compose run --rm app` to execute them inside the container.

```bash
# Run rspec tests
docker compose run --rm app bundle exec rspec spec/path/to/spec.rb

# Run a Rails runner command
docker compose exec app bundle exec rails runner "puts User.count"

# Run rake tasks
docker compose exec app bundle exec rake db:migrate

# Open a shell in the container
docker compose exec app bash

# View app logs
docker compose logs app -f --tail=100

# Restart the app (needed after changes to initializers or config)
docker compose restart app
```

Use `exec` when the app container is already running. Use `run --rm` for one-off commands (it starts a new container and removes it after).

## Running tests

```bash
# Run specific spec files
docker compose run --rm app bundle exec rspec spec/controllers/api/api_controller_spec.rb

# Run the full test suite
docker compose run --rm app ./docker/dev/run-spec.sh
```

## Project structure

- `rails/` — Main Rails application
- `docs/` — Design documents and specs

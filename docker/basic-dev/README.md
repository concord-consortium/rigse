```console
$ cd ./rails/
$ docker compose -f ../docker/basic-dev/docker-compose.yml start
$ nix develop
$ bundle exec rake assets:precompile
$ bundle exec rails db:setup
$ bundle exec rails server
```

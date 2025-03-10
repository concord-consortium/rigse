### Upgrade To Rails 8.0

1. Create an `upgrade-to-rails-8.0` branch off the `portal-upgrade` branch.
2. **A Ruby upgrade to 3.2 IS required**. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-3.2.0` in the `FROM` url.
3. Upgrade rails gems in `Gemfile` to last 8.0 version: `gem 'rails', '~> 8.0.1'`.
4. Inside running Docker image run `bundle update rails`
5. Resolve gem dependency issues until the bundle update succeeds.
6. Complete any upgrade tasks in the [7.2 to 8.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-2-to-rails-8-0). **At the time of writing, there were no tasks listed.**
7. Create a PR and insure all the tests pass.
8. After review/approval merge the branch into the `lara-upgrade` branch.

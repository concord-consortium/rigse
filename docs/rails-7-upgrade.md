### Upgrade To Rails 7.0.8.4

1. Create an `upgrade-to-rails-7.0` branch off the `portal-upgrade` branch.
2. Upgrade rails gems in `Gemfile` to last 7.0 version: `gem 'rails', '~> 7.0.8.7'`.
3. Inside running Docker image run `bundle update rails`
4. Resolve gem dependency issues until the bundle update succeeds.
5. Complete upgrade tasks in the [6.1 to 7.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)

- [X] ActionView::Helpers::UrlHelper#button_to changed behavior
- [X] Spring
- [X] Sprockets is now an optional dependency
- [X] Applications need to run in zeitwerk mode
- [X] The setter config.autoloader= has been deleted
- [X] ActiveSupport::Dependencies private API has been deleted
- [X] Autoloading during initialization
- [X] Ability to configure config.autoload_once_paths
- [X] ActionDispatch::Request#content_type now returns Content-Type header as it is.
- [X] Key generator digest class change requires a cookie rotator
- [X] Digest class for ActiveSupport::Digest changing to SHA256
- [X] New ActiveSupport::Cache serialization format
- [X] Active Storage video preview image generation
- [X] Active Storage default variant processor changed to :vips
- [X] Rails version is now included in the Active Record schema dump

6. Create a PR and insure all the tests pass.
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 7.1.4

1. Create an `upgrade-to-rails-7.1` branch off the `lara-upgrade` branch.
2. Upgrade rails gems in `Gemfile` to last 7.1 version: `gem 'rails', '~> 7.1.5'`.  No Ruby upgrade is required.
3. Inside running Docker image run `bundle update rails`
4. Resolve gem dependency issues until the bundle update succeeds.
5. Complete upgrade tasks in the [7.0 to 7.1 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)

- [ ] Development and test environments secret_key_base file changed
- [ ] Autoloaded paths are no longer in $LOAD_PATH
- [ ] config.autoload_lib and config.autoload_lib_once
- [ ] ActiveStorage::BaseController no longer includes the streaming concern
- [ ] MemCacheStore and RedisCacheStore now use connection pooling by default
- [ ] SQLite3Adapter now configured to be used in a strict strings mode
- [ ] Support multiple preview paths for ActionMailer::Preview
- [ ] config.i18n.raise_on_missing_translations = true now raises on any missing translation.
- [ ] bin/rails test now runs test:prepare task
- [ ] Import syntax from @rails/ujs is modified
- [ ] Rails.logger now returns an ActiveSupport::BroadcastLogger instance
- [ ] Active Record Encryption algorithm changes
- [ ] New ways to handle exceptions in Controller Tests, Integration Tests, and System Tests

7. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-2.7.0-rails-7.1.5` in the `FROM` url.
8. Create a PR and insure all the tests pass.
9. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 7.2.2

1. Create an `upgrade-to-rails-7.2` branch off the `lara-upgrade` branch.
2. **A Ruby upgrade to 3.1 IS required**. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-3.1.0` in the `FROM` url.
3. Upgrade rails gems in `Gemfile` to last 7.2 version: `gem 'rails', '~> 7.2.2'`.
4. Inside running Docker image run `bundle update rails`
5. Resolve gem dependency issues until the bundle update succeeds.
6. Complete upgrade tasks in the [7.1 to 7.2 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2)

- [ ] All tests now respect the active_job.queue_adapter config

7. Create a PR and insure all the tests pass.
8. After review/approval merge the branch into the `lara-upgrade` branch.

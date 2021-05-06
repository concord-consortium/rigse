# Rails 5 Upgrade Steps

0. Created PT stories for all top level items in the Rails Upgrade Guide.
1. First attempt to update to last 5.0 version of rails (5.0.7.2)
  1. Attempted upgrade by updating rails version in Gemfile and running `bundle update rails` inside a /bin/bash session in the app Docker container.  Got bundler error: `genigames_connector was resolved to 0.0.5, which depends on rails (~> 4.2)`
2. Attempted upgrading genigames_connector from 4.2 to 5.0
  1. Created `rails5-support` branch from `spike-rails4-support`
  2. Changed `s.add_dependency "rails", "~> 4.2"` to `s.add_dependency "rails", "~> 5"` in gemspec file and updated version in gem to 0.0.6
  3. Added `- ..:/projects` to volumes section of app in docker-compose.yml (this points to my root Concord projects folder)
  4. Ran the following in a rigse Docker bash session: `bundle config local.genigames_connector /projects/genigames-connector/`
  5. Changed rigse Gemfile to `gem 'genigames_connector', git: 'https://github.com/concord-consortium/genigames-connector.git', branch: 'rails5-support'`
  6. Reran `bundle update rails` but got `genigames_connector was resolved to 0.0.6, which depends on rails (~> 5)`
  7. Decided to punt upgrades of geni* gems until end of upgrade and removed projects volume
  8. Disabled geni* features
    1. Commented out gems in Gemfile
    2. Removed `PORTAL_FEATURES` environment variable in .env
    3. Restarted Docker container to ensure features are not enabled
3. Second attempt to update to last 5.0 version of rails (5.0.7.2)
  1. Changed rails version in Gemfile
  2. Based on this post (https://medium.com/nulogy/how-to-upgrade-your-legacy-app-from-4-2-to-rails-5-1-4eb681a864ae) deleted Gemfile.lock
  3. Ran `bundle install`
  4. Got `Bundler could not find compatible versions for gem "railties": devise (= 3.4.0) was resolved to 3.4.0, which depends on railties (>= 3.2.6, < 5)`
  5. Changed `gem 'devise', '3.4.0'` to `gem 'devise', '~> 3.5'`
  6. Reran `bundle install` and got `devise (~> 3.5) was resolved to 3.5.10, which depends on railties (< 5, >= 3.2.6)`
  7. Changed `gem 'devise', '3.4.0'` to `gem 'devise', '~> 4'` and got more errors
  8. Based on post in step 2 I started commenting out gems with a `# RE-ENABLE` comment above them
    1. devise
    2. tinymce-rails
    3. rake
  9. Added Gemfile.lock back
  10. Ran `bundle update rails`
  11. Disabled more gems
    1. prawn_rails
    2. themes_on_rails
    3. sextant
    4. sunspot_rails
    5. delayed_job
    6. delayed_job_active_record
    7. delayed_job_web
    8. paperclip
    9. pundit
    10. exception_notification
    11. nokogiri
    12. acts-as-taggable-on
    13. cucumber-rails
    14. coffee-rails
    15. devise-encryptable
    16. devise-token_authenticatable
    17. font-awesome-rails
  11. Ran `bundle update rails` again with success!
  12. Tested out deleting Gemfile.lock and running `bundle install` - this resulted in a **lot** of major upgrades
  13. Added Gemfile.lock back and reran `bundle update rails` to only update rails
  14. Ran `bundle clean`
  15. Started adding back commented out gems one at a time by uncommenting and running either `bundle install` or `bundle update <gem>` (if versioned and already installed as sub-dependency)
    1. cucumber-rails
    2. sextant
    3. rake
    4. themes_on_rails
    5. tinymce-rails
    6. sunspot_rails
    7. pundit
    8. prawn_rails
    9. paperclip
    10. nokogiri
    11. font-awesome-rails
    12. exception_notification
    13. acts-as-taggable-on (changed version from `~> 3.4.0` to `~> 4` as 3.4.0 doesn't support Rails 5)
    14. coffee-rails (changed version from `~> 4.0.0` to `~> 4.1.1` as 4.0.0 doesn't support Rails 5)
    15. devise (changed version from `3.4.0` to `4.0.0` as 3.4.0 doesn't support Rails 5)
    16. devise-encryptable
    17. devise-token_authenticatable
    18. delayed_job
    19. delayed_job_active_record
    20. delayed_job_web
  16. Diffed master with new Gemfile.lock to find major upgrades and build gemfile upgrade table below
    1. After initial diff tried to minimize major upgrades of the following
      1. paperclip 4.2.4 -> 6.1.0 (step 15) -> 4.2.4
      2. pundit 1.0.1 -> 2.1.0 (step 15) -> 1.0.1
    2. Not sure why I was able to revert back...
4. Getting rails to start back up from Docker container
  1. First run of docker-compose up
  2. Got startup error: `active_support/dependencies.rb:293:in require: cannot load such file`. This is coming from the delayed_job_web gem with uses sinatra 1 which has this bug: https://github.com/sinatra/sinatra/issues/1055
    1. Going to pin delayed_job_web in Gemfile from 1.2.5 (current) to 1.44 (latest) to see when sinatra updates
    2. Pinning delayed_job_web caused haml dependency error, setting haml from '~> 4.0' to '~> 4' which also caused error
  3. Going to comment out delayed_job_web for now
  4. Second run of docker-compose up
    1. Got a bunch of deprecation warnings
    2. Got startup error: `assert_index: No such middleware to insert before: ActionDispatch::ParamsParser (RuntimeError)`
    3. Step 2 is due to this line in application.rb: `config.middleware.insert_before("ActionDispatch::ParamsParser", "Rack::ExpandB64Gzip")`
    4. For now I'm going to comment out the middleware line
    5. Got startup error: `require: cannot load such file -- bullet/ (LoadError)`
    6. Going to comment out bullet in gemfile and bullet references in code
    7. Got startup error: `uninitialized constant DelayedJobWeb (NameError)`
    8. Going to comment out DelayedJobWeb reference in routes.db
    9. Got WEBrick running (with a lot of deprecation warnings)
  5. Address deprecation warnings
    1. Fixed
      1. ActiveRecord::Base.raise_in_transactional_callbacks= is deprecated, has no effect and will be removed without replacement.
      2. [Devise] config.email_regexp will have a new default on Devise 4.1
    2. Skipped for now (attempting to fix caused errors that need to be investigated)
      1. alias_method_chain is deprecated. Please, use Module#prepend instead. From module, you can access the original method using super. (called from block in <top (required)> at /rigse/config/initializers/00_rails-3-deprecate-duplicate-routes.rb:23)
      2. Passing string to define callback is deprecated and will be removed in Rails 5.1 without replacement. (lib/delayed/worker/scaler.rb:13,14,15)
      3. Passing strings or symbols to the middleware builder is deprecated, please change
        1. "ActionDispatch::Cookies" => ActionDispatch::Cookies
        2. "Rack::ConfigSessionCookies" => Rack::ConfigSessionCookies
        3. "Rack::ResponseLogger" => Rack::ResponseLogger
      4. Using a dynamic :controller segment in a route is deprecated and will be removed in Rails 5.2. (called from add_route_with_duplicate_route_deprecation at /rigse/config/initializers/    x. 00_rails-3-deprecate-duplicate-routes.rb:21)
      5. Using a dynamic :action segment in a route is deprecated and will be removed in Rails 5.2. (called from add_route_with_duplicate_route_deprecation at /rigse/config/initializers/    x. 00_rails-3-deprecate-duplicate-routes.rb:21)
  6. Got homepage loading!
  7. Removed `railslts-version` gem after push to GitHub immediately broke Travis
  8. Looked through all PT stories created from top level Rail Upgrade Guide and delivered all that needed no change to the code as 0 point stories with a comment about them not being needed.
  9. Estimated remaining PT stories
  10. Started on PT stories
    1. Default Template Handler is Now RAW (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#default-template-handler-is-now-raw)
      1. Ran the following one-liner to find the unique file extensions `find . -type f | rev | awk -F "." 'BEGIN { FS = "/" } ; {print $1}' | rev | awk 'BEGIN { FS = "." } ; {$1 = ""; print $0}' | sort | uniq`.  It output this list (the script replaces periods with spaces):
        - config builder
        - erb
        - haml
        - html erb
        - html haml
        - jnlp builder
        - pdf prawn
        - rjs
        - run_html haml
        - run_sparks_html haml
        - text erb
      2. I checked each extension and looked in the code to see how they were used.  I left a comment in the PT story (https://www.pivotaltracker.com/story/show/177670542/comments/223360555) asking Scott if he had any insight into the extensions I don't have any experience with.  I'm going to leave this PT story open for now.
    2. Rails Controller Testing (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#rails-controller-testing)
      1. Added `rails-controller-testing` gem as we are using `assigns` in a lot of tests and it was moved into this gem.
      2. Converted `ActionDispatch::Http::UploadedFile` to `Rack::Test::UploadedFile`
      3. These two changes are covered by a unit test but the tests still are not running due to startup issues.  There is a separate PT story for this.
    3. Halting Callback Chains via throw(:abort) (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#halting-callback-chains-via-throw-abort)
      1. Searched for all before callbacks in models
      2. Updated code in
        1. image.rb#check_image_presence to `throw(:abort)` instead of returning false
        2. portal/offering.rb from `before_destroy :can_be_deleted?` to `before_destroy :throw_abort_if_cant_be_deleted` where `throw_abort_if_cant_be_deleted` is a new method
    4. Rails Active Record Models Now Inherit from ApplicationRecord by Default (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#active-record-models-now-inherit-from-applicationrecord-by-default)
      1. Added application_record.rb model file
      2. Did a selective global search and replace for ActiveRecord::Base and replaced with ApplicationRecord (I left in old comments to ActiveRecord::Base but no code)
    5. New Framework Defaults (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#new-framework-defaults)
      1. Added section to each environment config with note and default values
      1. Active Record belongs_to Required by Default Option - leave at default of false
      2. Per-form CSRF Tokens - TBD!
      3. Forgery Protection with Origin Check - TBD!
      4. Allow Configuration of Action Mailer Queue Name - not needed, default is fine
      5. Support Fragment Caching in Action Mailer Views - TBD!
      6. Configure the Output of db:structure:dump - n/a only applies to PostgeSQL
      7. Configure SSL Options to Enable HSTS with Subdomains - TBD!
      8. Preserve Timezone of the Receiver - n/a only applies to Ruby 2.4, we use 2.2 currently
    6. Get tests starting
      1. Will be running `bundle exec rake db:migrate; bundle exec rake db:test:prepare; bundle exec rake db:feature_test:prepare` until it migrates
        1. Fixed `unknown keyword: class_name` error in delegate
        2. Added `reset_password_sent_at` to user table after getting error and reading devise docs and running `bundle exec rails generate devise user --force` and comparing generated user model with existing user model
      2. First ran `bundle exec rspec` and got repeated `can't modify frozen Array` but then researched and found out it was a red herring
      3. Based on comment on Stack Overflow looked for smallest spec test that had at least 1 test and found `user_mailer_spec.rb`
      4. Will be running `bundle exec rspec spec/models/user_mailer_spec.rb` until it starts
        1. Got `ArgumentError: Before process_action callback :authenticate_user! has not been defined` error in auth_controller.rb.  Fixed by adding `, :raise => false`
      5. Will be running `bundle exec rspec`
        1. Got many `NameError: uninitialized constant XXX` where `XXX` is the describe class name in the spec test.
        2. Fixed this by adding `config.enable_dependency_loading = true` to add environments where `config.eager_load` is true
    7. Default Template Handler is Now RAW (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#default-template-handler-is-now-raw)
      1. Reviewed all template handlers
      2. Removed home@report (used prawn)
      3. Removed prawn and prawn-rails gem and initializers and templates
      4. Remove destroy.rjs (should have been deleted in Rails 4 upgrade)
      5. Tested this first on master and Travis was green
      6. Rebased to rails5 branch from step 6
    8. protect_from_forgery Now Defaults to prepend: false (https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#protect-from-forgery-now-defaults-to-prepend-false)
      1. Tested first on master and Travis was green
      2. Rebased to rails5 branch from step 7
    9. Fix Rails 5.0 -> 5.1 deprecation warning messages
      1. Grabbed raw Travis log from step 6 and found unique deprecation errors
      2. Started document in tmp to track deprecations using hand formatted output from previous step.  Here is a summary with counts.
        - 1 Accessing mime types via constants is deprecated. Please change `Mime::HTML` to `Mime[:html]`.
        - 2 after_filter is deprecated and will be removed in Rails 5.1. Use after_action instead
        - 1 alias_method_chain is deprecated. Please, use Module#prepend instead. From module, you can access the original method using super.
        - 52 before_filter is deprecated and will be removed in Rails 5.1. Use before_action instead
        - 14 Comparing equality between `ActionController::Parameters` and a `Hash` is deprecated and will be removed in Rails 5.1. Please only do comparisons between instances of `ActionController::Parameters`. If you need to compare to a hash, first convert it using        `ActionController::Parameters#new`.
        - 2 confirm! is deprecated in favor of confirm
        - 4 Method symbolize_keys is deprecated and will be removed in Rails 5.1, as `ActionController::Parameters` no longer inherits from hash. Using this deprecated behavior exposes potential security problems. If you continue to use this method you may be creating a security vulnerability in your app that can be exploited. Instead, consider using one of these documented methods which are not deprecated: http://api.rubyonrails.org/v5.0.7.2/classes/ActionController/Parameters.html
        - 1 Method with_indifferent_access is deprecated and will be removed in Rails 5.1, as `ActionController::Parameters` no longer inherits from hash. Using this deprecated behavior exposes potential security problems. If you continue to use this method you may be creating a security vulnerability in your app that can be exploited. Instead, consider using one of these documented methods which are not deprecated: http://api.rubyonrails.org/v5.0.7.2/classes/ActionController/Parameters.html
        - 4 `:nothing` option is deprecated and will be removed in Rails 5.1. Use `head` method to respond with empty response body.
        - 2 Passing an argument to force an association to reload is now deprecated and will be removed in Rails 5.1. Please call `reload` on the result collection proxy instead.
        - 1 Passing conditions to delete_all is deprecated and will be removed in Rails 5.1. To achieve the same use where(conditions).delete_all.
        - 3 Passing strings or symbols to the middleware builder is deprecated, please change them to actual class references
        - 2 `redirect_to :back` is deprecated and will be removed from Rails 5.1. Please use `redirect_back(fallback_location: fallback_location)` where `fallback_location` represents the location to use if the request has no HTTP referer information.
        - 6 skip_before_filter is deprecated and will be removed in Rails 5.1. Use skip_before_action instead.
        - 1 This method was renamed to `#load_schema` and will be removed in the future. Use `#load_schema` instead.
        - 4 #to_hash unexpectedly ignores parameter filtering, and will change to enforce it in Rails 5.1. Enable `raise_on_unfiltered_parameters` to respect parameter filtering, which is the default in new applications. For the existing deprecated behaviour, call #to_unsafe_h instead.
        - 19 uniq is deprecated and will be removed from Rails 5.1 (use distinct instead)
        - 2 Using a dynamic :action segment in a route is deprecated and will be removed in Rails 5.2.
        - LOTS! Using positional arguments in functional tests has been deprecated, in favor of keyword arguments, and will be removed in Rails 5.1.
        - 45 Using positional arguments in integration tests has been deprecated, in favor of keyword arguments, and will be removed in Rails 5.1.
        - 22 `xhr` and `xml_http_request` are deprecated and will be removed in Rails 5.1. Switch to e.g. `post :create, params: { comment: { body: 'Honey bunny' } }, xhr: true`.
      3. Looked around for automated ways to fix these warnings
        1. Installed rubocop-rails gem and used `bundle exec rubocop --only Rails/HttpPositionalArguments -a` to fix almost all deprecation warnings about positional argurments -- needed to change use of xhr first for the update to fix everything (which is deprecated). Once the update was done I uninstalled rubocop. More info here: https://stackoverflow.com/a/58095264
    10. Fix broken Rails 4 -> 5.0 tests
      1. Fixed undefined method `distinct' for []:Array
      2. Fixed invalid SQL generation in searchable_model caused by change in how Rails 5 generates SQL when a where condition of [""] is given
      3. Fixed removing milliseconds from doubled model compares
      4. Fixed check for empty string in clazzes controller
      5. Added activemodel-serializers-xml gem to add to_xml back to ActiveRecord
      5. Fixed boolean string conversions (eg !!"false") to use new Rails 5 ActiveModel::Type::Boolean.new.cast method
      6. Fixed can't quote RSpec::Mocks::Double in user_spec
      7. Fixed user_spec where factory wasn't used but model was reloaded causing error
      8. Fixed establish_connection requires symbol parameter instead of string
      9. Fixed missing format in students controller spec


## Rails 4 -> 5.0 TODO
  1. Gemfile: add back geni* gems
  2. Gemfile: add back delayed_job_web
  3. application.rb: add back Rack::ExpandB64Gzip middleware
  4. Gemfile: add back bullet
  5. development.rb: add back Bullet.xxx references
  6. routes.rb: add back DelayedJobWeb reference
  7. Remove all "RAILS UPGRADE" comments

## Rails 4 -> 5.0 Gemfile Upgrade Table

|gem                         | From      | To      |
|----------------------------|-----------|---------|
|acts-as-taggable-on         | 3.4.4     | 4.0.0   |
|coffee-rails                | 4.0.1     | 4.1.1   |
|cucumber-rails              | 1.4.5     | 1.7.0   |
|delayed_job                 | 4.1.1     | 4.1.9   |
|delayed_job_active_record   | 4.1.0     | 4.1.6   |
|delayed_job_web             | 1.2.9     | 1.2.5   |
|devise                      | 3.4.0     | 4.0.0   |
|devise-encryptable          | 0.1.1     | 0.2.0   |
|devise-token_authenticatable| 0.3.2     | 0.5.3   |
|font-awesome-rails          | 4.7.0.1   | 4.7.0.7 |
|prawn_rails                 | 0.0.8     | 0.0.11  |
|rails                       | 4.2.11.17 | 5.0.7.2 |
|sunspot_rails               | 2.2.5     | 2.5.0   |

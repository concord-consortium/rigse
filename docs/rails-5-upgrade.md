# Rails 5 Upgrade Steps

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






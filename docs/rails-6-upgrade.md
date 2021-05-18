# Rails 6 Upgrade Steps

1. Created PT stories for all top level items in the Rails Upgrade Guide.
2. Upgraded rails gem to 6.0.3.7
  a. Pinned `bootsnap` gem to earlier version (1.4.4) based on note in the docs since we are using Ruby 2.5
  b. Unpinned `newrelic_npm` gem to fix startup error
  c. Disabled code in mime type initializer that had an empty string for the mime type - this causes a runtime error in Rails 6
  d. Set `config.hosts = nil` in application.rb - otherwise you have to whitelist all domains including dev at app.rigse.docker
  e. Added `/app/helpers/**/"` to autoload paths.  In `classic` mode now the autoloader only loads 1 subdirectory below app automatically
  f. Disabled `themes_on_rails` due to a startup error


## TODO

1. Find all `RAILS6` comments and address them
2. Re-enable `themes_on_rails`
  a. refer to changes in these commits: 7190256 08d4f9da5a
    1. in `application controller:41` -- Disabled theme :get_theme
    2. in `application.rb:169`  -- loads learn/all.css
    3. added `app/assets/stylesheets/learn/all.scss`
  b. Use sass class scopes for managing styles, and project specific stylesheets
    1. app/assets/projects/projectname.sass
    2. define everything within a top scope `.project-name-theme` { }
    3. add a css class to the body tag matching `.project-name-theme` for the
    current theme.
  c. Replace theme based view templates
    1. add some partial view rendering tests (backport to master?)
      - spec for app/views/home/home.html.haml
      - spec for app/views/home/about.html.haml
      - just FYI those are rendered through routes:
        - `home home#index` and
        - `home home#about`
      - view partial rendering for mailers?
    2. add/expand theme helper to dynamically render partials for the theme.
      - views/home/_project_info
      - views/home/_project_summary
      - views/shared/_email_banner
      - views/shared/_footer
      - views/shared/_logo
      - _email_banner
        - rails/app/views/password_mailer/forgot_password.html.erb:
        - rails/app/views/portal/clazz_mailer/clazz_assignment_notification.html.erb:11
        - rails/app/views/portal/clazz_mailer/clazz_creation_notification.html.erb:11
        - rails/app/views/user_mailer/confirmation_instructions.html.erb:11

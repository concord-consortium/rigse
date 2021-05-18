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
  a. Re-enable `themes_on_rails`
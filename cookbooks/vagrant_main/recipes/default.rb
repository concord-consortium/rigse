include_recipe "apt"
include_recipe "mysql::server"
include_recipe "passenger_apache2::mod_rails"
include_recipe "xml"

execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

web_app "project" do
  template "rails_app.conf.erb"
  docroot "/vagrant/public"
  rails_env "development"
  notifies :reload, resources(:service => "apache2"), :delayed
end

# add stuff for nokogiri
# the package name varies depending on the plaform
# there is a chef api to handle this but for now it is hardcoded
package "libxslt1-dev"

# this is needed by the nces importer
package "unzip"

# install bundler
gem_package 'bundler'


execute "bundle-install" do
  cwd "/vagrant"
  command "bundle install"
end

execute "setup-xportal-app" do
  cwd "/vagrant"
  command "ruby config/setup.rb -n 'Cross Project Portal' -D xproject -u root -p '' -t xproject -y -q -f"
end

execute "initialize-xportal-database" do
  cwd "/vagrant"
  environment ({'RAILS_ENV' => 'production'})
  command "rake db:migrate:reset"
end

execute "setup-xportal-database" do
  cwd "/vagrant"
  environment ({'RAILS_ENV' => 'production'})
  command "rake app:setup:new_app"
end


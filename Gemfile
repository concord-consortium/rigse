require "yaml"
YAML::ENGINE.yamler= "psych" if defined?(YAML::ENGINE)

source "http://rubygems.org"

#### COMMON
  gem "mysql2",             '~> 0.3', :platforms => [:ruby,:mingw]

  platforms :jruby do
    gem "activerecord-jdbcmysql-adapter",  "~> 1.1.3"
    gem "jruby-openssl",                   "~> 0.7.4"
    gem "ffi-ncurses",                     "~> 0.3.3"
  end

  platforms :mingw do
    gem "win32-open3"
  end

  
  gem "rails",                "~> 3.2"
  gem "arrayfields"
  gem "httpclient",           "~> 2.2"
  gem "capistrano-ext",                 :require => "capistrano"
  gem "aasm",                 "~> 2.2.1"
  gem "will_paginate",        "~> 3.0.0"
  gem "haml",           :git => "git://github.com/concord-consortium/haml.git", :branch => "xml-mime-type-and-ie8-keycode-fix"
  
  gem "RedCloth",             "~> 4.2.8"
  gem "uuidtools",            "~> 2.1.2"
  gem "spreadsheet",          "~> 0.7.3"  #see http://spreadsheet.rubyforge.org/

  # ruby-ole is a spreadsheet dependency but v1.2.11.1 doesn't work on Ruby 1.9.3
  gem "ruby-ole",             "~> 1.2.11.2"
  
  gem "prawn",                "~> 0.12.0"
  gem 'prawn_rails',          "~> 0.0.6"

  gem "grit",                 "~> 2.4"
  gem "open4",                "~> 1.0"
  gem "jnlp",                 "~> 0.7.3"
  # # use a merge of ghazel and tracksimple ar-extensions forks
  # # for mysql2, remove of deprecation warnings, and fixing gemspec so it works with bundler
  # # git "git://github.com/concord-consortium/ar-extensions.git" do
  # #   gem "ar-extensions",        "~> 0.9.3"
  # # end
  gem "activerecord-import",  "~> 0.2.8"
  # gem "fastercsv",            "~> 1.5"
  gem "net-sftp",             "~> 2.0",   :require => "net/sftp"
  gem "redcarpet",            "~> 2.1.1"
  gem "syntax",               "~> 1.0"
  gem "paperclip",            "~> 2.4.0"
  gem "acts-as-taggable-on",  "~> 2.1.1"
  gem "acts_as_list",         "~> 0.1.6"
  gem "nokogiri",             "~> 1.5.0"
  gem 'rdoc',                 "~> 3.9.4"
  gem 'themes_for_rails',     "~> 0.5.1"
  gem 'default_value_for',    "~> 2.0.1"
  gem 'exception_notification', "~> 2.5.2"
  gem 'prototype-rails'
  # switch to willbryant inorder to pick up some 3.1 necessary changes
  gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/willbryant/prototype_legacy_helper.git'
  gem "in_place_editing",     "~> 1.2.0"
  gem 'dynamic_form',         "~> 1.1.4"
  gem 'json',                 "~> 1.6.3"
  # need patched version of calendar_data_select to work in rails 3.1 and higher
  # this is because of the removed RAILS_ROOT constant
  gem 'calendar_date_select', :git => 'git://github.com/courtland/calendar_date_select'
  gem 'delayed_job',          "~> 3.0.1"
  gem 'delayed_job_active_record', "~> 0.3.2"
  gem 'daemons',              "~> 1.1.8"
  gem 'rush',                 :git => 'git://github.com/concord-consortium/rush'
  # to support hosting paperclip attachments on S3:
  gem "aws-s3",               :require => "aws/s3"
  gem "newrelic_rpm"

group :assets do
  # gem "sass",                 "~> 3.1.7"
  gem 'sass-rails' # if running rails 3.1 or greater
  gem "compass-rails"
  gem 'uglifier'
  gem 'yui-compressor'
end

group :development do
  gem "rake",                 "~> 0.9.2"
  gem "highline"
  gem "wirble"
  gem "what_methods"
  gem "hirb"
  gem "ruby-debug",   :platforms => [:mri_18, :mingw_18]
  gem "debugger", :platforms => [:mri_19]
  gem "awesome_print"
  gem "interactive_editor"
  gem "pry"
end

group :test do
  gem "selenium-webdriver", "2.25.0"
  gem "cucumber",          "~> 1.1.9"
  gem "cucumber-rails",    "~> 1.3.0", :require => false
  gem "database_cleaner",  "~> 0.7.2"
  gem "capybara",          "~> 1.1.2"
  gem "rspec",             "~> 2.9.0"
  gem "rspec-rails",       "~> 2.9.0"
  gem "email_spec",        "~> 1.2.1"
  gem "fakeweb",           "~> 1.3", :require => false
  gem "ci_reporter",       "~> 1.7.0"
  gem "delorean",           "~> 1.1"
end

group :test, :development do
  gem "factory_girl",      "~> 2.0.5"
  gem "remarkable_activerecord",  "~> 3.1.13", :require => nil
  gem "launchy",           "~> 2.0.5"
  # TODO: Use spork or not?
  gem "spork",              "~> 0.9.0.rc9"
end

source "http://rubygems.org"

#### COMMON
  platforms :ruby do
    if ENV['RB_MYSQL2']
      gem "mysql2",             '< 0.3'
    else
      gem "mysql",              "~>2.7"
    end
  end

  platforms :jruby do
    gem "rake",                            ">= 0.9.2"
    gem "activerecord-jdbcmysql-adapter",  "~> 1.1.3"
    gem "jruby-openssl",                   "~> 0.7.4"
    gem "ffi-ncurses",                     "~> 0.3.3"
  end

  gem "rails",                "~> 3.0.10"
  gem "arrayfields"
  gem "httpclient",           "~> 2.2"
  gem "capistrano-ext",                 :require => "capistrano"
  gem "aasm",                 "~> 2.2.1"
  gem "will_paginate",        "~> 2.3.15"
  gem "haml",                 "~> 3.1.1"
  gem "RedCloth",             "~> 4.2.8"
  gem "uuidtools",            "~> 2.1.2"
  gem "spreadsheet"  #see http://spreadsheet.rubyforge.org/
  gem "prawn",                "~> 0.12.0"
  gem "prawn-format",         "~> 0.2.3", :require => "prawn/format"
  gem 'prawn_rails',          "~> 0.0.6"
  gem "grit",                 "~> 2.4"
  gem "open4",                "~> 1.0"
  gem "compass",              "~> 0.11.5"
  gem "jnlp",                 "~> 0.7.3"
  # # use a merge of ghazel and tracksimple ar-extensions forks
  # # for mysql2, remove of deprecation warnings, and fixing gemspec so it works with bundler
  # # git "git://github.com/concord-consortium/ar-extensions.git" do
  # #   gem "ar-extensions",        "~> 0.9.3"
  # # end
  gem "fastercsv",            "~> 1.5"
  gem "net-sftp",             "~> 2.0",   :require => "net/sftp"
  gem "maruku",               "~> 0.6"
  gem "syntax",               "~> 1.0"
  gem "paperclip",            "~> 2.4.0"
  gem "acts-as-taggable-on",  "~> 2.1.1"
  gem "nokogiri",             "~> 1.5.0"
  gem 'rdoc',                 "~> 3.9.4"
  gem 'themes_for_rails',     "~> 0.4.2"
  gem 'soap4r-ruby1.9',       "~> 2.0.3"
  gem 'default_value_for'

group :development do
  gem "highline"
  gem "wirble"
  gem "what_methods"
  gem "hirb"
  gem "ruby-debug",   :platforms => :mri_18
  gem "ruby-debug19", :platforms => :mri_19
  gem "awesome_print"
  gem "interactive_editor"
  gem "pry"
end

group :test do
  gem "cucumber",          "~> 1.0.2"
  gem "cucumber-rails",    "~> 1.0.2"
  gem "database_cleaner",  "~> 0.6.7"
  gem "capybara",          "~> 1.0.1"
  gem "rspec",             "~> 2.6"
  gem "rspec-rails",       "~> 2.6"
  gem "factory_girl",      "~> 2.0.5"
  gem "email_spec",        "~> 1.2.1"
  gem "fakeweb",           "~> 1.3"
  gem "remarkable_rails",  "~> 3.1.13", :require => nil
  # If you update the version of ci_reporter
  # please make sure to update the --require path in Hudson
  gem "ci_reporter",       "~> 1.6.5"
  gem "launchy",           "~> 2.0.5"
  # TODO: Use spork or not?
  gem "spork",              "~> 0.8"
  gem "delorean",           "~> 1.1"
  # See: http://wiki.github.com/dchelimsky/rspec/spork-autospec-pure-bdd-joy
  # and: http://ben.hoskings.net/2009/07/16/speedy-rspec-with-rails
  # gem "ZenTest",                  "= 4.1.4"
  # gem "autotest-rails",           "= 4.1.0"

end

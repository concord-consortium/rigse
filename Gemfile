source "http://rubygems.org"

#### COMMON
  platforms :ruby do
    if ENV['RB_MYSQL2']
      gem "mysql2",             "0.2.7"
    else
      gem "mysql",              "~>2.7"
    end
  end

  platforms :jruby do
    gem "rake",                            ">= 0.9.1"
    gem "activerecord-jdbcmysql-adapter",  "~> 1.1"
    gem "jruby-openssl",                   "~> 0.7"
    gem "ffi-ncurses",                     "~> 0.3.3"
  end

  # gem "mongrel",              "~> 1.1.5"
  gem "rails",                "~> 3.0.7"
  gem "arrayfields"
  gem "httpclient",           "~> 2.2"
  gem "capistrano-ext",                 :require => "capistrano"
  gem "aasm",                 "~> 2.2.0"
  gem "will_paginate",        "~> 2.3.15"
  gem "haml",                 "~> 3.1.1"
  gem "RedCloth",             "~> 4.2.7"
  gem "uuidtools",            "~> 2.1.2"
  gem "spreadsheet"  #see http://spreadsheet.rubyforge.org/
  gem "prawn",                "~> 0.11.1"
  gem "prawn-format",         "~> 0.2.3", :require => "prawn/format"
  gem "grit",                 "~> 2.4"
  gem "open4",                "~> 1.0"
  gem "compass",              "~> 0.11.1"
  gem "jnlp",                 "~> 0.7.1"
  # # use a merge of ghazel and tracksimple ar-extensions forks
  # # for mysql2, remove of deprecation warnings, and fixing gemspec so it works with bundler
  # # git "git://github.com/concord-consortium/ar-extensions.git" do
  # #   gem "ar-extensions",        "~> 0.9.3"
  # # end
  gem "fastercsv",            "~> 1.5"
  gem "net-sftp",             "~> 2.0",   :require => "net/sftp"
  gem "maruku",               "~> 0.6"
  gem "syntax",               "~> 1.0"
  gem "paperclip"
  gem "acts-as-taggable-on"
  gem "nokogiri",             "~> 1.4.4"
  gem 'rdoc',                 "~> 3.6.1"

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
  gem "cucumber",          "~> 0.10"  #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber"))
  gem "cucumber-rails",    "~> 0.5"   #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber-rails"))
  gem "database_cleaner",  "~> 0.6"   #unless File.directory?(File.join(Rails.root, "vendor/plugins/database_cleaner"))
  gem "capybara",          "~> 1.0.0.beta1"   #unless File.directory?(File.join(Rails.root, "vendor/plugins/capybara"))
  gem "rspec",             "~> 2.6"   #unless File.directory?(File.join(Rails.root, "vendor/plugins/rspec"))
  gem "rspec-rails",       "~> 2.6"   #unless File.directory?(File.join(Rails.root, "vendor/plugins/rspec-rails"))
  gem "factory_girl",      "~> 1.3"
  gem "email_spec",        "~> 1.1"
  gem "fakeweb",           "~> 1.3"
  gem "remarkable_rails",  "~> 3.1.13", :require => nil
  # If you update the version of ci_reporter
  # please make sure to update the --require path in Hudson
  gem "ci_reporter",       "~> 1.6.4"
  gem "launchy",           "~> 0.4"
  # TODO: Use spork or not?
  gem "spork",              "~> 0.8"
  gem "delorean",           "~> 1.0"
  # See: http://wiki.github.com/dchelimsky/rspec/spork-autospec-pure-bdd-joy
  # and: http://ben.hoskings.net/2009/07/16/speedy-rspec-with-rails
  # gem "ZenTest",                  "= 4.1.4"
  # gem "autotest-rails",           "= 4.1.0"

end

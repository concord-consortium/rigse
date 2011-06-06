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
    gem "rake",                            ">=0.8.7"
    gem "activerecord-jdbcmysql-adapter",  ">=0.9.2"
    gem "jruby-openssl",                   ">=0.6"
    gem "ffi-ncurses",                      "~>0.3.3"
  end

  gem "rails",                "2.3.11"
  gem "arrayfields"
  gem "hpricot",              "0.6.164"
  gem "httpclient",           "~> 2.1.5.2"
  gem "capistrano-ext",                   :require => "capistrano"
  gem "aasm",                 "~> 2.0.2"
  gem "will_paginate",        "~> 2.3.6"
  gem "haml",                 "~> 3.0.25"
  gem "RedCloth",             "~> 4.2.7"
  gem "uuidtools",            "~> 2.1.2"
  gem "spreadsheet"  #see http://spreadsheet.rubyforge.org/
  gem "prawn",                "~> 0.4.1"
  gem "grit",                 "~> 2.0.0"
  gem "open4",                "~> 0.9.6"
  gem "prawn-format",         "~> 0.1.1", :require => "prawn/format"
  gem "compass",              "~> 0.10.0"
  gem "jnlp",                 "~> 0.7.2"
  # use a merge of ghazel and tracksimple ar-extensions forks
  # for mysql2, remove of deprecation warnings, and fixing gemspec so it works with bundler
  git "git://github.com/concord-consortium/ar-extensions.git" do
    gem "ar-extensions",        "~> 0.9.3"
  end
  gem "fastercsv",            "   1.5.0"
  gem "net-sftp",             "   2.0.2",   :require => "net/sftp"
  gem "maruku",               "~> 0.6"
  gem "syntax",               "~> 1.0"
  gem "paperclip"
  gem "acts-as-taggable-on"
  gem "nokogiri",             "~> 1.4.4"

  #git "/Users/npaessel/lab/ruby/deep_cloneable", :branch => "cloneable_assocations" do
  git "git://github.com/concord-consortium/deep_cloneable.git", :branch => "cloneable_assocations" do
    gem "deep_cloneable"
  end

group :development do
  gem "highline"
  gem "wirble"
  gem "what_methods"
  gem "hirb"
  gem "ruby-debug",     :platforms => :mri_18
end

group :test do
  #gem "gherkin",           "~>2.3"
  gem "cucumber",          "~>0.10.0" #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber"))
  gem "cucumber-rails",    "~>0.3.2" #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber-rails"))
  gem "database_cleaner",  "~>0.6.6" #unless File.directory?(File.join(Rails.root, "vendor/plugins/database_cleaner"))
  gem "capybara",          "~>0.4" #unless File.directory?(File.join(Rails.root, "vendor/plugins/capybara"))
  gem "rspec",             "~>1.3.0" #unless File.directory?(File.join(Rails.root, "vendor/plugins/rspec"))
  gem "rspec-rails",       "~>1.3.2" #unless File.directory?(File.join(Rails.root, "vendor/plugins/rspec-rails"))
  gem "factory_girl",      "= 1.2.3"
  gem "email_spec",        "= 0.3.5"
  gem "fakeweb",           "~>1.2.8"
  gem "remarkable_rails",  "~>3.1.13", :require => nil
  # If you update the version of ci_reporter
  # please make sure to update the --require path in Hudson
  gem "ci_reporter",       "~>1.6.4"
  gem "launchy"
  # TODO: Use sport or not?
  gem "spork"
  gem "delorean"
  # See: http://wiki.github.com/dchelimsky/rspec/spork-autospec-pure-bdd-joy
  # and: http://ben.hoskings.net/2009/07/16/speedy-rspec-with-rails
  # gem "ZenTest",                  "= 4.1.4"
  # gem "autotest-rails",           "= 4.1.0"

end

source :gemcutter

#### COMMON
  gem "mysql",                "~>2.7"
  gem "mongrel",              "~>1.1.5"
  gem "rails",                "2.3.11"
  gem "arrayfields"
  gem "hpricot",              "0.6.164"
  gem "httpclient",           "~> 2.1.5.2"
  gem "capistrano-ext",                   :require => "capistrano"
  gem "aasm",                 "~> 2.0.2"
  gem "will_paginate",        "~> 2.3.6"
  gem "haml",                 "~> 3.0.25"
  gem "RedCloth",             "~> 4.1.1"
  gem "uuidtools",            "~> 2.0.0"
  gem "spreadsheet"  #see http://spreadsheet.rubyforge.org/
  gem "prawn",                "~> 0.4.1"
  gem "grit",                 "~> 2.0.0"
  gem "open4",                "~> 0.9.6"
  gem "prawn-format",         "~> 0.1.1", :require => "prawn/format"
  gem "compass",              "0.8.17"
  gem "jnlp",                 "0.6.2"
  # use https://github.com/zdennis/activerecord-import istead of
  # ar-extensions
  # gem "ar-extensions",        "~> 0.9.1"
  gem "fastercsv",            "   1.5.0"
  gem "net-sftp",             "   2.0.2",   :require => "net/sftp"
  gem "maruku",               "~> 0.6"
  gem "syntax",               "~> 1.0"
  gem "paperclip"
  gem "acts-as-taggable-on"
  gem "ruby-debug"
  gem "nokogiri",             "~> 1.4.1"
group :development do
  gem "highline"
end

group :test do
  #gem "gherkin",           "~>2.3"
  gem "cucumber",          "~>0.10.0" #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber"))
  gem "cucumber-rails",    "~>0.3.2" #unless File.directory?(File.join(Rails.root, "vendor/plugins/cucumber-rails"))
  gem "database_cleaner",  "~>0.5.0" #unless File.directory?(File.join(Rails.root, "vendor/plugins/database_cleaner"))
  gem "capybara",          "~>0.3.8" #unless File.directory?(File.join(Rails.root, "vendor/plugins/capybara"))
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



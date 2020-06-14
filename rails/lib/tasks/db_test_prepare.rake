namespace :db do
  namespace :test do

    desc 'after completing standard db:test:prepare load default data'
    task :prepare do
      ActiveRecord::Base.establish_connection Rails.env.to_sym

      if Rails.env == 'cucumber' || Rails.env == 'feature_test'
        require File.expand_path('../../../spec/spec_helper.rb', __FILE__)
        APP_CONFIG[:password_for_default_users] = 'password'
        Rake::Task['app:setup:create_default_data'].invoke
      end
    end

    desc "prepare db for feature"
    task :prepare_cucumber do
      Rails.env = ENV['RAILS_ENV'] = 'cucumber'
      Rake::Task['db:test:prepare'].invoke
    end

  end
end

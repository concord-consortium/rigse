namespace :db do
  namespace :test do

    def load_common_data
      Rake::Task['db:backup:load_probe_configurations'].invoke
      Rake::Task['db:backup:load_ri_grade_span_expectations'].invoke
    end

    desc 'after completing db:test:prepare load probe configurations'
    task :prepare do
      Rails.env = ENV['RAILS_ENV'] = (ENV['RAILS_ENV'] == 'cucumber' ? 'cucumber' : 'test')
      ActiveRecord::Base.establish_connection Rails.env.to_sym

      load_common_data

      if Rails.env == 'cucumber'
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

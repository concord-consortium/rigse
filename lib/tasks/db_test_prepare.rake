namespace :db do
  namespace :test do
    def load_common_data
      Rake::Task['db:backup:load_probe_configurations'].invoke
      Rake::Task['db:backup:load_ri_grade_span_expectations'].invoke
    end

    desc 'after completing db:test:prepare load probe configurations'
    task :prepare do
      Rails.env = ENV['RAILS_ENV'] = (ENV['RAILS_ENV'] == 'cucumber' ? 'cucumber' : 'test')
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:schema:load'].invoke
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env])
      load_common_data

      if Rails.env == 'cucumber'
        require File.expand_path('../../../spec/spec_helper.rb', __FILE__)
        APP_CONFIG[:password_for_default_users] = 'password'
        Rake::Task['app:setup:create_default_data'].invoke
      end
    end
  end
end


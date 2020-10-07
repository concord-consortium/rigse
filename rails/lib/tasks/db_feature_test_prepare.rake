namespace :db do
  namespace :feature_test do

    # This is a subset of active-record/database.rake db:test:purge
    desc "Empty the feature_test database"
    task :purge => [:environment, 'db:load_config'] do
      ActiveRecord::Tasks::DatabaseTasks.purge ActiveRecord::Base.configurations['feature_test']
    end

    desc "prepare db for feature and cucumber tests"
    task :prepare => ['db:abort_if_pending_migrations', :purge] do
      # Disable the active record logging
      ActiveRecord::Base.logger.level = 1

      # This is copied from active-record/database.rake db:test:load_schema
      # ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['feature_test'])
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Tasks::DatabaseTasks.load_schema_for ActiveRecord::Base.configurations['feature_test'], :ruby, ENV['SCHEMA']
      # end of db:test_load_schema copy

      require File.expand_path('../../../spec/spec_helper.rb', __FILE__)
      APP_CONFIG[:password_for_default_users] = 'password'

      puts "Loading default data into database: #{ActiveRecord::Base.connection.current_database}"
      Rake::Task['app:setup:create_default_data'].invoke
    end

  end
end

namespace :db do
  namespace :feature_test do

    # This is a subset of active-record/database.rake db:test:purge
    desc "Empty the feature_test database"
    task :purge => [:environment, 'db:load_config'] do
      ActiveRecord::Tasks::DatabaseTasks.purge 'feature_test'
    end

    desc "prepare db for feature and cucumber tests"
    task :prepare => ['db:abort_if_pending_migrations', :purge] do
      # Disable the active record logging
      ActiveRecord::Base.logger.level = 1

      # This is copied from active-record/database.rake db:test:load_schema
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Tasks::DatabaseTasks.load_schema ActiveRecord::Base.configurations.configs_for(env_name: 'feature_test'), :ruby, ENV['SCHEMA']
      # end of db:test_load_schema copy
    end

  end
end

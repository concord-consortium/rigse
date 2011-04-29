namespace :db do
  namespace :test do
    
    desc 'after completing db:test:prepare load probe configurations'
    task :prepare do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      Rake::Task['db:backup:load_probe_configurations'].invoke
      Rake::Task['db:backup:load_ri_grade_span_expectations'].invoke
    end

  end
end
    
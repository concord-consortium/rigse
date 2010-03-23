namespace :hudson do
  
  def report_path
    "hudson/reports/features/"
  end

  if defined? Cucumber
    Cucumber::Rake::Task.new({:cucumber  => [:report_setup, 'db:migrate', 'db:test:prepare']}) do |t|
      t.cucumber_opts = %{--profile default  --format junit --out #{report_path} --format html --out #{report_path}/report.html}
    end
  end

  task :report_setup do
    rm_rf report_path
    mkdir_p report_path
  end
  
  desc "Run the cucumber and RSpec tests, but don't fail until both suites have run."
  task :everything do
    tasks = {"cucumber" => ["hudson:cucumber"], "test" => ["hudson:spec"] }
    exceptions = []
    tasks.each do |env,tasks|
      ENV['RAILS_ENV'] = env
      tasks.each do |t|
        begin
          Rake::Task[t].invoke
        rescue => e
          exceptions << e
        end
      end
    end
    exceptions.each do |e|
      puts "Exception encountered:"
      puts "#{e}\n#{e.backtrace.join("\n")}"
    end
    raise "Test failures" if exceptions.size > 0
  end
  
  task :spec => ["hudson:setup:rspec", 'db:migrate', 'db:test:prepare', 'rake:spec']

  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = 'hudson/reports/spec/'
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
    end
    task :rspec => [:pre_ci, "ci:setup:rspec"]
  end
end
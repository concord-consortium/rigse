namespace :hudson do

  def cucumber_report_path
    "hudson/reports/features/"
  end

  def rspec_report_path
    "hudson/reports/spec/"
  end

  if defined? Spec
    Spec::Rake::SpecTask.new do |t|
      t.spec_opts = %{--profile default  --format CI::Reporter::RSpec --format html:#{rspec_report_path}report.html}
    end
  end

  if defined? Cucumber
    task_dependencies = [:cucumber_report_setup, 'db:migrate', 'db:test:prepare']
    opts = %{--profile default --tags ~@dialog  --format junit --out #{cucumber_report_path} --format html --out #{cucumber_report_path}report.html}
    Cucumber::Rake::Task.new({:cucumber  => task_dependencies}) do |t|
      t.cucumber_opts = opts
    end
    Cucumber::Rake::Task.new({:cucumber_selenium_only  => task_dependencies}) do |t|
         t.cucumber_opts = opts + " --tags @selenium"
    end
    Cucumber::Rake::Task.new({:cucumber_skip_theme_todo  => task_dependencies}) do |t|
      t.cucumber_opts = opts + " --tags ~@#{ENV['THEME']}-todo"
    end
  end

  task :spec_report_setup do
    rm_rf rspec_report_path
    mkdir_p rspec_report_path
  end

  task :cucumber_report_setup do
    rm_rf cucumber_report_path
    mkdir_p cucumber_report_path
  end

  desc "Run the cucumber and RSpec tests, but don't fail until both suites have run."
  task :everything do
    tasks = {"cucumber" => ["hudson:cucumber_skip_theme_todo"], "test" => ["hudson:spec"] }
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

  desc "run the RSpec tests"
  task :spec => ["hudson:setup:rspec", :spec_report_setup, 'db:migrate', 'db:test:prepare', 'rake:spec']

  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = rspec_report_path
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
    end
    task :rspec => [:pre_ci, "ci:setup:rspec"]
  end
end

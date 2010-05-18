require 'rubygems'

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'

def gem_install_command_strings(missing_gems)
  command = JRUBY ? "  jruby -S gem install " : "  sudo gem install "
  command + missing_gems.collect {|g| "#{g[0]} -v '#{g[1]}'"}.join(' ') + "\n"
end

@development_gems = [['hpricot', '= 0.6.164'], ['rspec', '>= 1.3.0'], ['ci_reporter', '>= 1.6.0']]
@missing_gems = []
@development_gems.each do |gem_name_and_version|
  begin
    gem gem_name_and_version[0], gem_name_and_version[1]
  rescue Gem::LoadError
    @missing_gems << gem_name_and_version
  end
end

unless @missing_gems.empty?
  message = <<-HEREDOC

The following gem(s) need to be installed to run, test and package the jnlp gem.

  #{gem_install_command_strings(@missing_gems.reverse)}

  HEREDOC
  raise message
end

require 'spec/rake/spectask'

require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'jnlp.rb')

task :default => :spec

desc 'run spec tests (the default task)'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

desc "generate the gem package: jnlp-#{Jnlp::VERSION}.gem"
task :package do
  system "gem build jnlp.gemspec"
end

desc "push the packaged gem: jnlp-#{Jnlp::VERSION}.gem to rubygems.org"
task :release => :package do
  system "gem push jnlp-#{Jnlp::VERSION}.gem"
end

namespace :hudson do
  desc "run the spec tests and generate JUnit XML reports (for integrating with a Hudson CIS server)"
  task :spec => ["hudson:setup:rspec", 'rake:spec']

  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = 'spec/reports/'
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
    end
    task :rspec => [:pre_ci, "ci:setup:rspec"]
  end
end

# Documentation tasks
#
# You can generate the doc by hand as follows:
#
#   rdoc -U --main=README.rdoc --title='Jnlp::Jnlp' README.rdoc History.txt License.txt lib
#
#   yardoc -o ydoc - README.rdoc History.txt License.txt

begin
  # try using the rdoc gem if it is installed
  require 'rdoc/task'
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.template = "darkfish"
    rdoc.main = "README.rdoc"
    rdoc.title = 'Jnlp::Jnlp'
    rdoc.rdoc_files.include("README.rdoc", 'History.txt', 'License.txt', "lib/**/*.rb")
    rdoc.options += ['-f', 'darkfish']
  end
rescue LoadError
  # else use Rake's rdoc task (but this won't use the darkfish template)
  require 'rake/rdoctask'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.main = "README.rdoc"
    rdoc.title = 'Jnlp::Jnlp'
    rdoc.rdoc_files.include("README.rdoc", 'History.txt', 'License.txt', "lib/**/*.rb")
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |ydoc|
    ydoc.files   = ["README.rdoc", 'History.txt', 'License.txt', "lib/**/*.rb"]
    ydoc.options = ['-o', 'ydoc', '--main', 'README.rdoc']
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc: sudo gem install yard"
  end
end

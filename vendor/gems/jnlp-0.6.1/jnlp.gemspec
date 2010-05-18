GEM_ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift File.join(GEM_ROOT, 'lib')
require 'jnlp'

Gem::Specification.new do |s|
  s.name = 'jnlp'
  s.version = Jnlp::VERSION
  s.authors = ["Stephen Bannasch"]
  s.email = 'stephen.bannasch@gmail.com'
  s.homepage = 'http://rubywebstart.rubyforge.org/jnlp/rdoc'
  s.summary = %q{Ruby tools for working with Java Web Start JNLPs.}
  s.description = %q{For manipulation of Java Web Start Jnlps and the resources they reference.}
  s.date = '2010-02-11'
  s.rubyforge_project = 'rubywebstart'

  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = %w{ History.txt License.txt README.rdoc}
  
  s.required_rubygems_version = ">= 1.3.2"
  s.require_path = 'lib'

  s.files =  Dir.glob("{lib,spec}/**/*.{rb}") + %w{ History.txt License.txt README.rdoc Rakefile jnlp.gemspec }

  s.add_runtime_dependency('hpricot', "= 0.6.164")  
  s.add_development_dependency("rspec", '>= 1.3.0')
  s.add_development_dependency("ci_reporter", '>= 1.6.0')
end

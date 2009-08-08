require 'rubygems'
require 'hoe'

require './lib/jnlp.rb'

Hoe.new('jnlp', Jnlp::VERSION) do |p|
  p.rubyforge_name = 'rubywebstart' # if different than lowercase project name
  p.author = 'Stephen Bannasch'
  p.email = 'stephen.bannasch@gmail.com'
  p.url = 'http://rubywebstart.rubyforge.org/jnlp/rdoc/'
  p.summary = "Ruby tools for working with Java Web Start JNLPs."
  p.description = "For manipulation of Java Web Start Jnlps and the resources they reference."
  p.extra_deps << ['hpricot','=0.6.164']
end

task :default => :spec
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

require 'rubygems'
require 'hoe'

require './lib/jnlp.rb'

Hoe.spec 'jnlp' do |spec|
  spec.rubyforge_name = 'rubywebstart' # if different than lowercase project name
  spec.author = 'Stephen Bannasch'
  spec.email = 'stephen.bannasch@gmail.com'
  spec.url = 'http://rubywebstart.rubyforge.org/jnlp/rdoc/'
  spec.summary = "Ruby tools for working with Java Web Start JNLPs."
  spec.description = "For manipulation of Java Web Start Jnlps and the resources they reference."
  spec.extra_deps << ['hpricot','=0.6.164']
end

task :default => :spec
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

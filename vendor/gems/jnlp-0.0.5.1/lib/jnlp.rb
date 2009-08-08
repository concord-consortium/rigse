$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

gem 'hpricot', '=0.6.164'

module Jnlp
  require 'jnlp/jnlp.rb'
  require 'jnlp/otrunk.rb'
  require 'jnlp/maven_jnlp.rb'
  require 'jnlp/version.rb'
end
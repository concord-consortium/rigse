require 'rake'
require 'hpricot'

namespace :setup do
 
  #
  #
  #
  desc 'import grade span expectations from file config/rigse_data.xhtml'
  task :import_from_file do
    load 'config/environment.rb'
    parser = Parser.new
    parser.parse("config/rigse_data.xhtml")
  end

end
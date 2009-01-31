require 'rake'
require 'hpricot'

namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data.xhtml'
    task :import_from_file do
      load 'config/environment.rb'
      parser = Parser.new
      parser.parse(File.join [RAILS_ROOT] + %w{config rigse_data.xhtml})
    end
  end
end
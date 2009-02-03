require 'rake'
require 'hpricot'

namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/*'
    task :import_from_file => :environment do
      parser = Parser.new
      parser.process_rigse_data
    end
  end
end
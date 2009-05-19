require 'rake'
require 'hpricot'

namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/*'
    task :import_gses_from_file => :environment do
      puts <<-HEREDOC

*** import grade span expectations from file config/rigse_data/*
*** This task normally produces many warnings and errors ...

HEREDOC
      
      parser = Parser.new
      parser.process_rigse_data
    end
  end
end
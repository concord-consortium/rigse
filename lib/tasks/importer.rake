namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/*'
    task :import_gses_from_file => :environment do
      require 'hpricot'
      
      puts <<-HEREDOC

*** import grade span expectations from file config/rigse_data/*
*** This task normally produces many warnings and errors ...

HEREDOC
      
      parser = Parser.new
      parser.process_rigse_data
    end    
  end
  namespace :convert do
    desc 'set new grade_span_expectation attribute: gse_key'
    task :set_gse_keys => :environment do
      gses = GradeSpanExpectation.find(:all)
      puts "resetting gse_key for #{gses.length} GradeSpanExpectations"
      gses.each { |gse|  gse.set_gse_key }
    end
  end
end
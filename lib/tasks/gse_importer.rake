namespace :app do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/*'
    task :import_gses_from_file => :environment do
      require 'hpricot'
      
      # save the investigations that have related gses, along 
      # with the assessment_target_id and grade_span of the gse
      investigations_with_gses = Investigation.find(:all).find_all {|i| i.grade_span_expectation_id != nil}
      if investigations_with_gses
        puts "Saving gse specification from #{investigations_with_gses.length} Investigations ..."
        inv_gse_cache = investigations_with_gses.collect  do |inv|
          gse = inv.grade_span_expectation
          puts "  Investigation: #{inv.id}: #{inv.name}, GSE: #{gse.id}: #{gse.gse_key}, #{gse.assessment_target_id}, #{gse.grade_span}, '#{gse.assessment_target.description}'"
          [inv, gse.assessment_target.description, gse.grade_span]
        end
      end
      
      puts <<-HEREDOC

*** import grade span expectations from file config/rigse_data/*
*** This task normally produces many warnings and errors ...

HEREDOC
      
      gse_parser = GseParser.new
      gse_parser.process_rigse_data
      
      # if any investigations had gses then find the updated gse by looking for the
      # unique combination of of the saved gse assessment_target_id and grade_span 
      # (the primary key and even the gse_key of the new gses might have been updated)
      # and then update the investigation to reference the new gse
      if investigations_with_gses
        puts "\nRestoring gse relationship for #{investigations_with_gses.length} Investigations ..."
        inv_gse_cache.each do |inv_spec|
          assessment_target = RiGse::AssessmentTarget.find_by_description(inv_spec[1])
          if assessment_target
            gse = RiGse::GradeSpanExpectation.find_by_grade_span_and_assessment_target_id(inv_spec[2], assessment_target.id)
          end
          inv = inv_spec[0]
          print "  Investigation: #{inv.id}: #{inv.name}, GSE: "
          if gse
            inv.grade_span_expectation = gse
            inv.save!
            puts "#{gse.id}: #{gse.gse_key}, #{gse.assessment_target_id}, #{gse.grade_span}, '#{gse.assessment_target.description}'"
          else
            inv.grade_span_expectation = nil
            inv.save!
            puts "nil"
          end
        end
      end
    end
  end
  
  namespace :convert do
    desc 'set new grade_span_expectation attribute: gse_key'
    task :set_gse_keys => :environment do
      gses = RiGse::GradeSpanExpectation.find(:all)
      puts "resetting gse_key for #{gses.length} RiGse::GradeSpanExpectations"
      gses.each { |gse|  gse.set_gse_key }
    end
  end
end
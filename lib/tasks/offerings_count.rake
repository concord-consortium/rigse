namespace :offerings do
  
  desc "recalculate the 'offerings_count' field for runnable objects"
  task :set_counts => :environment  do
    updating_models = %w(Investigation Activity ResourcePage Page Portal::Teacher)
    updating_models.each_with_index do |c, i|    
      puts "Updating #{c.pluralize} (step #{i+1} of #{updating_models.size}) ..."
      c.classify.constantize.all.each do |rec|
        rec.update_attribute(:offerings_count, rec.offerings.count)
      end
    end
  end
  
end

namespace :offerings do
  
  desc "recalculate the 'offerings_count' field for runnable objects"
  task :set_counts => :environment  do
    %w(Investigation ResourcePage Page Portal::Teacher).each do |c|    
      c.classify.constantize.all(:include => :offerings).each do |rec|
        rec.update_attribute(:offerings_count, rec.offerings.size)
      end
    end
  end
  
end
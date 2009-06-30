require 'rake'

namespace :rigse do
  namespace :convert do
    desc 'reclaim un-owned page-elements (by using the owner for the containing page...)'
    task :reclaim_elements => :environment do
       investigations = Investigation.find(:all).each do |i|
         current_user = i.user 
         if (current_user)
           puts "working with #{current_user.login}"
           i.deep_set_user(current_user)
         else
           puts "skipping investigation #{i.name} : #{i.id} which has no owner!"
           next
         end
       end  
    end
    desc 'run deep_set_user on each owned investigation using the current owner of the investigation)'
    task :run_deep_set_user_on_all_investigations => :environment do
       Investigation.find(:all).each do |inv|
         if owner = inv.user
           puts " deep_set_user: #{owner.login} => Investigation: #{inv.id}: #{inv.name}"
           inv.deep_set_user(owner)
         else
           puts "skipping investigation #{i.name} : #{i.id} which has no owner!"
           next
         end
       end  
    end
  end
end
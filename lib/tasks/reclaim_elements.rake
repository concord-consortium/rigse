require 'rake'

namespace :app do
  namespace :convert do
    desc 'run deep_set_user on each owned investigation using the current owner of the investigation)'
    task :run_deep_set_user_on_all_investigations => :environment do
       Investigation.find_in_batches(:batch_size => 100) do | batch |
         batch.each do |inv|
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
    
    desc 'remove teacher notes without an authored entity. reclaim ownership of '
    task :clean_teacher_notes => :environment do
      TeacherNote.find(:all).each do |note|
        dirty = false
        if note.authored_entity
          if note.authored_entity.user
            unless note.authored_entity.user == note.user
              puts "chaing owner of teacher note #{note.id} to #{note.authored_entity.user.login}"
              note.user = note.authored_entity.user
              note.save
            end
          end
        end
      end
    end
  end
end
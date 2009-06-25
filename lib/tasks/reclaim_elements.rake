require 'rake'

namespace :rigse do
  namespace :convert do
    desc 'reclaim un-owned page-elements (by using the owner for the containing page...)'
    task :reclaim_elements => :environment do
       investigations = Investigation.find(:all)
        investigations.each do |i|
          current_user = i.user 
          if (current_user)
            puts "working with #{current_user.login}"
          else
            puts "skipping investigation #{i.name} : #{i.id} which has no owner!"
            next
          end
          i.activities.each do |a|
            if (a.user.nil?)
              puts "no user for section #{a.name}: #{a.id} will change to #{current_user.login}"
              a.user = current_user;
              a.save!
            end
            a.sections.each do |s|
              if (s.user.nil?)
                puts "no user for section #{s.name}: #{s.id} will change to #{current_user.login}"
                s.user = current_user;
                s.save!
              end
              s.pages.each do |p|
                if (p.user.nil?)
                  puts "no user for page #{p.name}: #{p.id} will change to #{current_user.login}"
                  p.user = current_user;
                  p.save!
                end
                p.page_elements.each do |elem|
                  embedable = elem.embeddable
                  if (embedable)
                    user = embedable.user
                    if (!user)
                      puts "no user for #{embedable.class.name}: #{embedable.id} will change to #{current_user.login}"
                      embedable.user = current_user
                      embedable.save!
                    end
                  end
                end
              end
            end
          end
        end
    end
  end
end
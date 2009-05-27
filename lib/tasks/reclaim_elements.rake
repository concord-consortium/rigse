require 'rake'

namespace :rigse do
  namespace :convert do
    desc 'reclaim un-owned page-elements (by using the owner for the containing page...)'
    task :reclaim_elements => :environment do
       investigations = Activity.find(:all)
        investigations.each do |i|
          i.sections.each do |s|
            s.pages.each do |p|
              p.page_elements.each do |elem|
                current_user = p.user
                if (current_user)
                  puts "working with #{current_user.login}"
                else
                  puts "skipping page with no owner!"
                  next
                end
                embedable = elem.embeddable
                if (embedable)
                  user = embedable.user
                  if (!user)
                    puts "no user for #{embedable.class.name}: #{embedable.id} will change to #{current_user}"
                    embedable.user = current_user
                    embedable.save!
                  end
                else
                  puts "no #{embedable} for #{elem}"
                end
              end
            end
          end
        end
    end
  end
end
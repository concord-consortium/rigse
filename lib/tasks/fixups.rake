require 'rake'

namespace :rigse do
  namespace :convert do

    desc 'Add the author role to all users who have authored an Investigation'
    task :add_author_role_to_authors => :environment do
      User.find(:all).each do |user|
        if user.has_investigations?
          print '.'
          STDOUT.flush
          user.add_role('author')
        end
      end
      puts
    end

    desc 'Remove the author role from users who have not authored an Investigation'
    task :remove_author_role_from_non_authors => :environment do
      User.find(:all).each do |user|
        unless user.has_investigations?
          print '.'
          STDOUT.flush
          user.remove_role('author')
        end
      end
      puts
    end

    desc 'transfer any Investigations owned by the anonymous user to the site admin user'
    task :transfer_investigations_owned_by_anonymous => :environment do
      admin_user = User.find_by_login(APP_CONFIG[:admin_login])
      anonymous_investigations = User.find_by_login('anonymous').investigations
      if anonymous_investigations.length > 0
        puts "#{anonymous_investigations.length} Investigations owned by the anonymous user"
        puts "resetting ownership to the site admin user: #{admin_user.name}"
        anonymous_investigations.each do |inv|
          inv.deep_set_user(admin_user)
          print '.'
          STDOUT.flush
        end
      else
        puts 'no Investigations owned by the anonymous user'
      end
    end
    
    
    desc 'ensure investigations have publication_status'
    task :pub_status => :environment do
      Investigation.find(:all).each do |i|
        if i.publication_status.nil?
          i.update_attribute(:publication_status,'draft')
        end
      end
    end
    
  end
end


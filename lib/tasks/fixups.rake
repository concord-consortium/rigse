require 'rake'

namespace :rigse do
  namespace :convert do

    desc 'Add the author role to all users who have authored an Investigation'
    task :add_author_role_to_authors => :environment do
      User.find(:all).each do |user|
        if user.has_investigations?
          print '.'
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
          user.remove_role('author')
        end
      end
      puts
    end

    desc 'transfer any Investigations owned by the anonymous user to the admin user'
    task :transfer_investigations_owned_by_anonymous => :environment do
      admin_user = User.find_by_login(APP_CONFIG[:admin_login])
      User.find_by_login('anonymous').investigations.each do |inv|
        puts "transferring ownership of #{inv.id}: #{inv.name} from anonymous to #{admin_user.login}"
        inv.deep_set_user(admin_user)
      end
    end
  end

end
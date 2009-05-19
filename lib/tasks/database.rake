require 'rake'

namespace :db do
  desc "Dump the current database to a MySQL file" 
  task :dump => :environment do
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    case db_config["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(db_config)
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        cmd = "mysqldump"
        if db_config["host"]
          cmd << " -h #{db_config["host"]}"
        end
        if db_config["username"]
          cmd << " -u #{db_config["username"]}"
        end
        if db_config["password"]
          cmd << " -p#{db_config["password"]}"
        end
        cmd << " #{db_config["database"]}"
        # puts "Fetching database\n#{cmd}"
        puts "Saving database to: db/#{RAILS_ENV}_data.sql"
        f << `#{cmd}`
      end
    when 'sqlite3'
      ActiveRecord::Base.establish_connection(db_config)
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        f << `sqlite3  #{db_config["database"]} .dump`
      end
    else
      raise "Task not supported by '#{db_config['adapter']}'" 
    end
  end
end
namespace :db do
  desc "Dump the current database to a MySQL file" 
  task :dump => :environment do
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    case db_config["adapter"]
    when 'mysql', 'mysql2'
      # make sure we can connect to the db...
      ActiveRecord::Base.establish_connection(db_config)
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        cmd = "mysqldump --lock-tables=false --add-drop-table --quick --extended-insert"
        if db_config["host"]
          cmd << " -h #{db_config["host"]}"
        end
        if db_config["username"]
          cmd << " -u #{db_config["username"]}"
        end
        if db_config["password"]
          cmd << " -p'#{db_config["password"]}'"
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
  
  require 'active_record'
  class RemoveTables < ActiveRecord::Migration
    def self.up
      ActiveRecord::Base.connection.tables.each do |table|
        drop_table(table)
      end
    end
    
    def self.down
    end
  end
  
  task :load => :environment do
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    
    RemoveTables.up
    
    case db_config["adapter"]
    when 'mysql', 'mysql2'
      cmd = "mysql"
      if db_config["host"]
        cmd << " -h #{db_config["host"]}"
      end
      if db_config["username"]
        cmd << " -u #{db_config["username"]}"
      end
      if db_config["password"]
        cmd << " -p'#{db_config["password"]}'"
      end
      db_path = "db/#{RAILS_ENV}_data.sql"
      `gunzip --force #{db_path}.gz` if File.exists? db_path + '.gz'
      cmd << " #{db_config["database"]} < #{db_path}"
      # puts "Fetching database\n#{cmd}"
      puts "Loading database from: #{db_path}"
      puts `#{cmd}`
    when 'sqlite3'
      ActiveRecord::Base.establish_connection(db_config)
      puts`sqlite3  #{db_config["database"]} < #{db_path}`
    else
      raise "Task not supported by '#{db_config['adapter']}'" 
    end
  end
end
require 'rake'
require 'hpricot'

#
# adapted from:
#   http://www.samsaffron.com/archive/2008/02/02/Redo+your+migrations+in+Rails+and+keep+your+data

def interesting_tables
  tables = ActiveRecord::Base.connection.tables.sort
  tables.reject! do |tbl|
    %w{schema_migrations sessions roles_users}.include?(tbl)
  end
  tables
end

namespace :db do
  namespace :backup do

    desc "Reload the database and rerun migrations" 
    task :redo do 
      Rake::Task['db:backup:write'].invoke
      Rake::Task['db:reset'].invoke
      Rake::Task['db:backup:read'].invoke 
    end 

    desc "Saves the db to yaml fixures in config/db/backup." 
    task :save => :environment do 
      dir = RAILS_ROOT + '/config/db_backup'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir) do
        interesting_tables.each do |tbl|
          klass = tbl.classify.constantize
          File.open("#{tbl}.yaml", 'w') do |f| 
            attributes = klass.find(:all).collect { |m| m.attributes }
            f.write YAML.dump(attributes)
          end
        end
      end
    end

    desc "Loads the db from yaml fixures in config/db/backup" 
    task :load => [:environment] do 
      dir = RAILS_ROOT + '/config/db_backup'
      FileUtils.chdir(dir) do
        interesting_tables.each do |tbl|

          ActiveRecord::Base.transaction do 

            begin 
              klass = tbl.classify.constantize
              klass.destroy_all
              klass.reset_column_information

              puts "Loading #{tbl}..." 
              table_path = "#{tbl}.yaml"
              YAML.load_file(table_path).each do |fixture|
                data = {}
                klass.columns.each do |c|
                  # filter out missing columns 
                  data[c.name] = fixture[c.name] if fixture[c.name]
                end
                ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{data.keys.map{|kk| "#{tbl}.#{kk}"}.join(",")}) VALUES (#{data.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
              end        
            rescue 
              puts "failed to load table #{tbl}" 
            end 
          end
        end
      end
    end


    desc "Load just the probe configurations from yaml fixtures in config/probeconfigurations." 
    task :load_probe_configurations => :environment do 
      dir = RAILS_ROOT + '/config/probe_configurations'
      FileUtils.chdir(dir) do
        tables = %w{device_configs data_filters vendor_interfaces physical_units calibrations probe_types}
        tables.each do |tbl|

          ActiveRecord::Base.transaction do 

            begin 
              klass = tbl.classify.constantize
              klass.destroy_all
              klass.reset_column_information

              puts "Loading #{tbl}..." 
              table_path = "#{tbl}.yaml"
              YAML.load_file(table_path).each do |fixture|
                data = {}
                klass.columns.each do |c|
                  # filter out missing columns 
                  data[c.name] = fixture[c.name] if fixture[c.name]
                end
                ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{data.keys.map{|kk| "#{tbl}.#{kk}"}.join(",")}) VALUES (#{data.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
              end        
            rescue 
              puts "failed to load table #{tbl}" 
            end 
          end
        end
      end
    end
  end
end

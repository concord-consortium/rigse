#
# adapted from:
#   http://www.samsaffron.com/archive/2008/02/02/Redo+your+migrations+in+Rails+and+keep+your+data
# NOTE: 09-26-2009 knowuh: these migrations do not seem  to work with models which have our scoped name-spaces.
#

require 'fileutils'
require 'active_record/fixtures'

def db_username(enviro)
  dbconfig = YAML::load(File.open('config/database.yml'))
  dbconfig.fetch(enviro)["username"]
end

def db_password(enviro)
  dbconfig = YAML::load(File.open('config/database.yml'))
  dbconfig.fetch(enviro)["password"]
end

def db_database(enviro)
  dbconfig = YAML::load(File.open('config/database.yml'))
  dbconfig.fetch(enviro)["database"]
end

# something like this will ONLY WORKO ON MYSQL!
def clone_production
  %w|test development|.each do |enviro|
    puts "trying with environment #{enviro}"
    %x[ mysqldump --add-drop-table -u #{db_usernamex(enviro)} -p#{db_passwordx(enviro)}  #{db_databasex(enviro)} | mysql -u #{username('production')} -p#{password('production')} #{database('production')}  ]
  end
end

def interesting_tables
  tables = ActiveRecord::Base.connection.tables.sort
  tables.reject! do |tbl|
    %w{schema_migrations sessions roles_users admin_settings}.include?(tbl)
  end
  tables
end

namespace :db do
  desc "clone the production db to development and testing (MYSQL ONLY!)"
  task :clone do
    clone_production
  end

  namespace :backup do

    desc "Reload the database and rerun migrations"
    task :redo do
      Rake::Task['db:backup:write'].invoke
      Rake::Task['db:reset'].invoke
      Rake::Task['db:backup:read'].invoke
    end

    desc "Saves the db to yaml fixures in config/db/backup."
    task :save => :environment do
      dir = ::Rails.root.to_s + '/config/db_backup'
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir) do
        interesting_tables.each do |tbl|
          klass = tbl.classify.constantize
          File.open("#{tbl}.yaml", 'w') do |f|
            attributes = klass.all.collect { |m| m.attributes }
            f.write YAML.dump(attributes)
          end
        end
      end
    end

    desc "Loads the db from yaml fixures in config/db/backup"
    task :load => [:environment] do
      dir = ::Rails.root.to_s + '/config/db_backup'
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
                ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{data.keys.join(",")}) VALUES (#{data.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
              end
            rescue
              puts "failed to load table #{tbl}"
            end
          end
        end
      end
    end

    desc "Dump just the Factory Girl factory definitions from the current db"
    task :dump_defs_to_factory_girl => :environment do
      @just_factories = true
      Rake::Task['db:backup:dump_to_factory_girl'].invoke
    end

    desc "Dump the db to a rough Factory Girl format"
    task :dump_to_factory_girl => :environment do
      @skip_attrs = ["id", "created_at", "updated_at", "uuid"]
      @namespaced = {"admin_" => "Admin::", "dataservice_" => "Dataservice::", "otrunk_example_" => "OtrunkExample::", "portal_" => "Portal::"}
      # @non_rich_joins = ["jars_versioned_jnlps","portal_courses_grade_levels","portal_grade_levels_teachers"]
      ActiveRecord::Base.connection.tables.each do |table|
        print "Dumping #{table}... "
        tablename = table.singularize
        classname = ""
        @namespaced.each do |k,v|
          if table =~ /^#{k}/
            classname = ", :class => #{v}#{tablename.sub(/^#{k}/,'').classify}"
          end
        end

        cols = []
        ActiveRecord::Base.connection.columns(table).each do |col|
          cols << col.name
        end
        f = nil
        if cols.include?("id")
          f = File.open("#{::Rails.root.to_s}/features/factories/#{table}.rb", "w")
          f.write "FactoryBot.define do\n  factory :#{tablename}#{classname} do |f|\n"
          f.write "  end\nend\n\n"
        else
          if @just_factories
            # no op
          else
            f = File.open("#{::Rails.root.to_s}/features/factories/#{table}.rb", "w")
            f.write "# #{table}: This is a non-rich join table\n\n"
          end
        end
        objs = ActiveRecord::Base.connection.execute "SELECT * from #{table}"


        objs.each do |o|
          if ! @just_factories
            if cols.include?("id")
              write_factory(f,tablename,cols,o)
            else
              write_joins(f,table,cols,o)
            end
          end
        end
        if f
          f.flush
          f.close
        end
        print " done.\n"
      end
    end

    def write_factory(file, table, cols, vals)
      tvals = [cols,vals].transpose
      out_vals = []
      tvals.each do |val|
        next if @skip_attrs.include?(val[0])
        out_vals << ":#{val[0]} => '#{val[1].to_s.sub(/'/,'\\\'')}'"
      end
      file.write("FactoryBot.create(:#{table},{\n  " + out_vals.join(",\n  ") + "\n})\n")
    end

    def write_joins(file, table, cols, vals)
      return if @just_factories
      tvals = [cols,vals].transpose
      colArr = []
      valArr = []
      tvals.each do |val|
        next if @skip_attrs.include?(val[0])
        colArr << val[0]
        valArr << val[1].to_s.sub(/'/,'\\\'')
      end
      file.write("ActiveRecord::Base.connection.execute 'INSERT INTO #{table} (#{colArr.join(",")}) VALUES (#{valArr.join(",")})'\n")
    end
  end
end

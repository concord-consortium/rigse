namespace :app do
  namespace :jnlp do

    autoload :HighLine, 'highline'

    def wrapped_agree(prompt)
      if ENV['ANSWER_YES']
        true
      else
        HighLine.new.agree(prompt)
      end
    end
    
    desc "delete and re-generate MavenJnlp resources from jnlp servers in settings.yml"
    task :delete_and_regenerate_maven_jnlp_resources => [:delete_maven_jnlp_resources, :generate_maven_jnlp_resources] do
    end
    
    desc "generate names for existing MavenJnlpServers that don't have them"
    task :generate_names_for_maven_jnlp_servers => :environment do
       MavenJnlp::MavenJnlpServer.generate_names_for_maven_jnlp_servers
    end
    
    desc "generate MavenJnlp resources from jnlp servers in settings.yml"
    task :generate_maven_jnlp_resources => [:environment, :empty_jnlp_object_cache, :generate_names_for_maven_jnlp_servers] do
      puts <<-HEREDOC

Generate MavenJnlp family of resources from jnlp servers in settings.yml.

  Example from file: config/settings.yml:
  
    default_maven_jnlp_server: concord
    default_maven_jnlp_family: all-otrunk-snapshot
    maven_jnlp_families:
      - "all-otrunk-snapshot"
    default_jnlp_version: snapshot
    maven_jnlp_servers:
      - :name: concord
        :host: http://jnlp.concord.org
        :path: /dev/org/concord/maven-jnlp/

If you want to generate resources for all the MavenJnlp familes hosted on the MavenJnlp server
delete all the family names assigned to: maven_jnlp_families.

      HEREDOC

      maven_jnlp_servers = APP_CONFIG[:maven_jnlp_servers]
      if maven_jnlp_families = APP_CONFIG[:maven_jnlp_families]
        families = maven_jnlp_families.length
      else
        families = 'all'
      end
      maven_jnlp_servers.each do |server|
        if mj_server = MavenJnlp::MavenJnlpServer.find(:first, :conditions => server)
          puts "MavenJnlpServer: #{server.inspect} already exists."
        else
          puts "creating MavenJnlpServer: #{server.inspect}."
          mj_server = MavenJnlp::MavenJnlpServer.create!(server)
        end
      end
      
      servers = MavenJnlp::MavenJnlpServer.find(:all)
      servers.each do |mj_server|

        puts <<-HEREDOC

Generating: #{families} MavenJnlp families from this jnlp server specification:

  name: #{mj_server.name}
  host: #{mj_server.host}
  path: #{mj_server.path}

        HEREDOC

        if RAILS_ENV != 'development' || wrapped_agree("Do you want to do this? (y/n) ")
          mj_server.create_maven_jnlp_families
        end
        puts
      end
    end

    desc "erase cached jnlp resources in jnlp object cache directory"
    task :empty_jnlp_object_cache  => :environment do
      MavenJnlp::MavenJnlpServer.delete_all_cached_maven_jnlp_resources
    end
    
    desc "delete all the MavenJnlp resources"
    task :delete_maven_jnlp_resources => [:environment, :empty_jnlp_object_cache] do
      puts <<-HEREDOC

This will delete all the data in the following tables:

  MavenJnlp::MavenJnlpServer: #{MavenJnlp::MavenJnlpServer.count} records
  MavenJnlp::MavenJnlpFamily: #{MavenJnlp::MavenJnlpFamily.count} records
  MavenJnlp::VersionedJnlpUrl: #{MavenJnlp::VersionedJnlpUrl.count} records
  MavenJnlp::VersionedJnlp: #{MavenJnlp::VersionedJnlp.count} records
  MavenJnlp::Property: #{MavenJnlp::Property.count} records
  MavenJnlp::Jar: #{MavenJnlp::Jar.count} records
  MavenJnlp::Icon: #{MavenJnlp::Icon.count} records

      HEREDOC
      if wrapped_agree("Do you want to do this?  (y/n)" )
        
        MavenJnlp::MavenJnlpServer.delete_all_cached_maven_jnlp_resources
                
        # The TRUNCATE cammand works in mysql to effectively empty the database and reset 
        # the autogenerating primary key index ... not certain about other databases
        puts

        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::MavenJnlpServer.table_name}`")} from MavenJnlp::MavenJnlpServer"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::MavenJnlpFamily.table_name}`")} from MavenJnlp::MavenJnlpFamily"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::VersionedJnlpUrl.table_name}`")} from MavenJnlp::VersionedJnlpUrl"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::VersionedJnlp.table_name}`")} from MavenJnlp::VersionedJnlp"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::Property.table_name}`")} from MavenJnlp::Property"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::Jar.table_name}`")} from MavenJnlp::Jar"
        puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{MavenJnlp::Icon.table_name}`")} from MavenJnlp::Icon"

        MavenJnlp::MavenJnlpServer.reset_column_information
        MavenJnlp::MavenJnlpFamily.reset_column_information
        MavenJnlp::VersionedJnlpUrl.reset_column_information
        MavenJnlp::VersionedJnlp.reset_column_information
        MavenJnlp::Property.reset_column_information
        MavenJnlp::Jar.reset_column_information
        MavenJnlp::Icon.reset_column_information

        deleted_jars_versioned_jnlps = ActiveRecord::Base.connection.delete("DELETE FROM `jars_versioned_jnlps`")
        puts "deleted: #{deleted_jars_versioned_jnlps} from habtm join table: jars_versioned_jnlps"
        deleted_properties_versioned_jnlps = ActiveRecord::Base.connection.delete("DELETE FROM `properties_versioned_jnlps`")
        puts "deleted: #{deleted_properties_versioned_jnlps} from habtm join table: properties_versioned_jnlps"
        deleted_native_libraries_versioned_jnlps = ActiveRecord::Base.connection.delete("DELETE FROM `native_libraries_versioned_jnlps`")
        puts "deleted: #{deleted_native_libraries_versioned_jnlps} from habtm join table: native_libraries_versioned_jnlps"
        
        puts
      end
    end
  end
end

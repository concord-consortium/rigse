namespace :rigse do
  namespace :jnlp do
    
    # require 'highline/import'
    autoload :Highline, 'highline'
    
    desc "generate names for existing MavenJnlpServers that don't have them"
    task :generate_names_for_maven_jnlp_servers => :environment do
       MavenJnlp::MavenJnlpServer.generate_names_for_maven_jnlp_servers
    end
    
    desc "generate MavenJnlp family of resources from jnlp servers in settings.yml"
    task :generate_maven_jnlp_family_of_resources => :generate_names_for_maven_jnlp_servers do
      puts <<HEREDOC

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

        puts <<HEREDOC

Generating: #{families} MavenJnlp families from this jnlp server specification:

  name: #{mj_server.name}
  host: #{mj_server.host}
  path: #{mj_server.path}

HEREDOC

        if RAILS_ENV != 'development' || HighLine.new.agree("Do you want to do this? (y/n) ")  
          mj_server.create_maven_jnlp_families
        end
        puts
      end
    end

    desc "delete all the MavenJnlp resources"
    task :delete_maven_jnlp_resources => :environment do
      puts <<HEREDOC

This will delete all the data in the following tables:

  MavenJnlp::MavenJnlpServer: #{MavenJnlp::MavenJnlpServer.count} records
  MavenJnlp::MavenJnlpFamily: #{MavenJnlp::MavenJnlpFamily.count} records
  MavenJnlp::VersionedJnlpUrl: #{MavenJnlp::VersionedJnlpUrl.count} records
  MavenJnlp::VersionedJnlp: #{MavenJnlp::VersionedJnlp.count} records
  MavenJnlp::Property: #{MavenJnlp::Property.count} records
  MavenJnlp::Jar: #{MavenJnlp::Jar.count} records
  MavenJnlp::Icon: #{MavenJnlp::Icon.count} records

HEREDOC
      if HighLine.new.agree("Do you want to do this?  (y/n)")
        MavenJnlp::MavenJnlpServer.delete_all
        MavenJnlp::MavenJnlpFamily.delete_all
        MavenJnlp::VersionedJnlpUrl.delete_all
        MavenJnlp::VersionedJnlp.delete_all
        MavenJnlp::Property.delete_all
        MavenJnlp::Jar.delete_all
        MavenJnlp::Icon.delete_all
      end
    end
  end
end

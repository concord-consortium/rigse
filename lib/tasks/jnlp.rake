namespace :rigse do
  namespace :jnlp do
    
    require 'highline/import'
    
    desc "generate names for existing MavenJnlpServers that don't have them"
    task :generate_names_for_maven_jnlp_servers => :environment do
       MavenJnlp::MavenJnlpServer.generate_names_for_maven_jnlp_servers
    end
    
    desc "generate MavenJnlp family of resources from jnlp servers in settings.yml"
    task :generate_maven_jnlp_family_of_resources => :generate_names_for_maven_jnlp_servers do
      puts 
      puts
      maven_jnlp_servers = APP_CONFIG[:maven_jnlp_servers]
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

Generate MavenJnlp family of resources from this jnlp server specification?

  name: #{mj_server.name}
  host: #{mj_server.host}
  path: #{mj_server.path}

[this normally takes about 10 minutes]

HEREDOC
        if agree("Do you want to do this? (y/n) ", true)  
          mj_server.create_maven_jnlp_families
          puts <<HEREDOC
completed ...
#{mj_server.maven_jnlp_object.summarize}

HEREDOC
        else
          puts "\n  skipped ...\n"
        end
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
      if agree("Do you want to do this?  (y/n)", true)
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

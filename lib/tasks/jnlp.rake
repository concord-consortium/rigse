namespace :rigse do
  namespace :jnlp do
    
    require 'highline/import'
    
    desc "generate MavenJnlp family of resources from CC jnlp server"
    task :generate_maven_jnlp_family_of_resources => :environment do
      attributes = { :host => 'http://jnlp.concord.org', :path => '/dev/org/concord/maven-jnlp/' }
      unless mj = MavenJnlp::MavenJnlpServer.find(:first, :conditions => attributes)
        mj = MavenJnlp::MavenJnlpServer.create!(attributes)
      end
      puts <<HEREDOC

Generating MavenJnlp family of resources from CC jnlp server: 

  :host => #{attributes[:host]}
  :path => #{attributes[:path]}
  
HEREDOC
      mj.create_maven_jnlp_families
      puts <<HEREDOC
completed ...

#{mj.maven_jnlp_object.summarize}

HEREDOC
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

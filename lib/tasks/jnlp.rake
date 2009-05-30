namespace :rigse do
  namespace :jnlp do
    desc "generate MavenJnlp family of resources fron CC jnlp server"
    task :generate_maven_jnlp_family_of_resources => :environment do
      attributes = { :host => 'http://jnlp.concord.org', :path => '/dev/org/concord/maven-jnlp/' }
      unless mj = MavenJnlp::MavenJnlpServer.find(:first, :conditions => attributes)
        mj = MavenJnlp::MavenJnlpServer.create!(attributes)
      end
      mj.save!
      mj.create_maven_jnlp_families
    end
  end
end

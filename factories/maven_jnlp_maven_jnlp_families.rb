Factory.define :maven_jnlp_maven_jnlp_family, :class => MavenJnlp::MavenJnlpFamily do |f|
  f.name 'all-otrunk-snapshot'
  f.snapshot_version '0.1.0-20091013.161730' 
  f.url 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/'
  f.association :maven_jnlp_server, :factory => :maven_jnlp_maven_jnlp_server
end


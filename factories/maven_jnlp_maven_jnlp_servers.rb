Factory.define :maven_jnlp_maven_jnlp_server, :class => MavenJnlp::MavenJnlpServer do |f|
  f.host 'http://jnlp.concord.org'
  f.path '/dev/org/concord/maven-jnlp/'
  f.name 'concord'
end


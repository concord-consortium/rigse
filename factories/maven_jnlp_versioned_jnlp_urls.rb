Factory.define :maven_jnlp_versioned_jnlp_url, :class => MavenJnlp::VersionedJnlpUrl do |f|
  f.path  '/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
  f.url  'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
  f.date_str  '20091013.161730'
  f.version_str  '0.1.0-20091013.161730'
  f.association :maven_jnlp_family, :factory => :maven_jnlp_maven_jnlp_family
end


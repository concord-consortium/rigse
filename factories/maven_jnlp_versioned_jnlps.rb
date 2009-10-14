Factory.define :maven_jnlp_versioned_jnlp, :class => MavenJnlp::VersionedJnlp do |f|
  f.association :versioned_jnlp_url_id, :factory => :maven_jnlp_versioned_jnlp_url
  f.name  'all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
  f.main_class  'net.sf.sail.emf.launch.EMFLauncher3'
  f.argument  'dummy'
  f.offline_allowed  1
  f.spec  '1.0+'
  f.j2se_version  '1.5+'
  f.max_heap_size  '128'
  f.initial_heap_size  '32'
  f.codebase  'http://jnlp.concord.org/dev'
  f.href  'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20091013.161730.jnlp'
  f.title  'All OTrunk snapshot'
  f.vendor  'Concord Consortium'
  f.homepage  'index.html'
  f.description  'Preview Basic Pas'
end


class MavenJnlp::MavenJnlpFamily < ActiveRecord::Base
  set_table_name "maven_jnlp_maven_jnlp_families"
  
  belongs_to :maven_jnlp_server, :class_name => "MavenJnlp::MavenJnlpServer"
  has_many :versioned_jnlp_urls, :class_name => "MavenJnlp::VersionedJnlpUrl"
  # has_many :versioned_jnlps, :through => :versioned_jnlp_urls, :class_name => "MavenJnlp::VersionedJnlpUrl"
  
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def create_versioned_jnlp_urls(mjf_object)
    mjf_object.versions.each do |version_object|
      vju = self.versioned_jnlp_urls.build(
        :path        => version_object.path,
        :url         => version_object.url,
        :version_str => version_object.version)
      vju.save!
      print '.'; STDOUT.flush
    end
  end
  
  def update_snapshot_jnlp_url
    jnlp_url = snapshot_jnlp_url
    current = snapshot_version
    newest = newest_snapshot_version
    if current != newest
      jnlp_url = snapshot_jnlp_url.clone
      jnlp_url.url = jnlp_url.url.gsub(jnlp_url.version_str, newest)
      jnlp_url.path = jnlp_url.path.gsub(jnlp_url.version_str, newest)
      jnlp_url.version_str = newest
      jnlp_url.save!
      self.snapshot_version = newest
      self.save!
    end
    jnlp_url
  end

  def snapshot_jnlp_url
    MavenJnlp::VersionedJnlpUrl.find_by_version_str(snapshot_version)
  end

  def newest_snapshot_version
    begin
      open("#{url}/#{name}-CURRENT_VERSION.txt").read
    rescue OpenURI::HTTPError, SocketError
      snapshot_version
    end
  end
  
end

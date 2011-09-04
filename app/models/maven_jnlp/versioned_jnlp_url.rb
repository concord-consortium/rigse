class MavenJnlp::VersionedJnlpUrl < ActiveRecord::Base
  set_table_name "maven_jnlp_versioned_jnlp_urls"

  belongs_to :maven_jnlp_family, :class_name => "MavenJnlp::MavenJnlpFamily"
  has_one :versioned_jnlp, :class_name => "MavenJnlp::VersionedJnlp"

  acts_as_replicatable

  include Changeable

  self.extend SearchableModel

  @@searchable_attributes = %w{uuid path url version_str}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  before_save :update_date_str

  def update_date_str
    self.date_str = version_str[/-(.*)/, 1]
  end

  def versioned_jnlp
    MavenJnlp::VersionedJnlp.find_by_versioned_jnlp_url_id(self.id) || create_versioned_jnlp
  end

  def create_versioned_jnlp
    jnlp = MavenJnlp::VersionedJnlp.create(:versioned_jnlp_url_id => self.id)
  end

end

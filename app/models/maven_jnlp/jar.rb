class MavenJnlp::Jar < ActiveRecord::Base
  self.table_name = "maven_jnlp_jars"
  
  has_and_belongs_to_many :versioned_jnlps

  acts_as_replicatable
  
  include Changeable
  # include MavenJnlp::Resource
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name kind href version_str}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end

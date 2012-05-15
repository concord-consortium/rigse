class MavenJnlp::Icon < ActiveRecord::Base
  self.table_name = "maven_jnlp_icons"
  
  has_many :versioned_jnlps

  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid href}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
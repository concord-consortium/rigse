class MavenJnlp::Property < ActiveRecord::Base
  self.table_name = "maven_jnlp_properties"
  
  has_and_belongs_to_many :versioned_jnlp

  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name codebase href title vendor homepage description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end

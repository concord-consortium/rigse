class MavenJnlp::NativeLibrary < ActiveRecord::Base
  self.table_name = "maven_jnlp_native_libraries"
  
  has_and_belongs_to_many :versioned_jnlps
  # include MavenJnlp::Resource

  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name kind href version_str}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end

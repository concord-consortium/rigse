class Portal::Semester < ActiveRecord::Base
  set_table_name :portal_semesters
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  
  has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "semester_id", :source => :clazz
  
  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end
end

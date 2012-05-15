class Portal::Grade < ActiveRecord::Base
  self.table_name = :portal_grades
  
  acts_as_list
  acts_as_replicatable

  scope :active, { :conditions => { :active => true } }  
  has_many :grade_levels, :class_name => "Portal::GradeLevel"
  
  include Changeable
  
  ## suport for searching and pagination:
  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end
  
end

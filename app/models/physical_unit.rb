class PhysicalUnit < ActiveRecord::Base

  include Changeable
  
  acts_as_replicatable

  belongs_to :user
  has_many :calibrations
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def full_name
    "#{quantity}: #{name}"
  end
end

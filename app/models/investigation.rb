class Investigation < ActiveRecord::Base

  belongs_to :user
  has_many :activities, :order => :position, :dependent => :destroy
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  include Noteable # convinience methods for notes...

  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def self.display_name
    'Activity'
  end
  
end

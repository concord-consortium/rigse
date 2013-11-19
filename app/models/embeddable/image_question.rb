class Embeddable::ImageQuestion < ActiveRecord::Base
  self.table_name = "embeddable_image_questions" 
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages,:through =>:page_elements
  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  # Length validation removed 14Nov2013 - it's optional in LARA and the validation was preventing
  # publishing questions. See https://www.pivotaltracker.com/story/show/58968402 .
  # validates_length_of :prompt, :minimum => 1, :too_short => "You must provide a meaningful prompt to this question."
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name prompt drawing_prompt}
  
  class <<self
    
    def searchable_attributes
      @@searchable_attributes
    end

    def default_prompt
      "Please insert a snapshot of your drawings here."
    end
  end

  default_value_for :name, "Embeddable::ImageQuestion element"
  default_value_for :prompt, Embeddable::ImageQuestion.default_prompt


  def description
    prompt
  end
end

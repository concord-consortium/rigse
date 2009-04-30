class OpenResponse < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description prompt}

  class <<self
   def searchable_attributes
     @@searchable_attributes
   end
  end

  default_value_for :name, "Open Response Question"
  default_value_for :description, "What is the purpose of this question ...?"
  default_value_for :prompt, <<-HEREDOC
  <p>You can use HTML content to <b>write</b> the prompt of the question ...</p>
  HEREDOC
  default_value_for :default_response, "Place answer here!"
  
  
  def self.display_name
    "Open Response"
  end

end

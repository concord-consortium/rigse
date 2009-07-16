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
  default_value_for :default_response, "Please place your answer here."
  
  send_update_events_to :investigations
  
  def self.display_name
    "Open Response"
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end

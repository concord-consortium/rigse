class MultipleChoice < ActiveRecord::Base
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  
  
  default_value_for :name, "Further Investigation: cleaving a crystal"
  default_value_for :descrition, "This is an example take from Itroduction to Crystals"
  default_value_for :prompt, <<-HEREDOC
  You want to cleave a crystal.
  But scientists do not really all agree about how a crystal cut propagates or travels along a crystal. 
  Where might a break begin and how would it travel? Please provide a reasonable atomic-level hypothesis.
  HEREDOC
  default_value_for :default_response, "Place answer here!"
  
end

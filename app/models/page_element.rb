class PageElement < ActiveRecord::Base
    belongs_to :user
    belongs_to :page
    acts_as_list :scope => :page_id
    belongs_to :embeddable, :polymorphic => true

    def dom_id
      "page_element_#{self.id}"
    end
    
end

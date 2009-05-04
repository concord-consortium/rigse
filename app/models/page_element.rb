class PageElement < ActiveRecord::Base
    belongs_to :user
    belongs_to :page
    acts_as_list :scope => :page_id
    belongs_to :embeddable, :polymorphic => true

    include Changeable

    def before_destroy
      @embeddable = self.embeddable
    end
    
    def after_destroy
      @embeddable.reload
      if @embeddable.page_elements.empty?
        @embeddable.destroy
      end
    end

    def dom_id
      "page_element_#{self.id}"
    end
    
end

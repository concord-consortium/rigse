class PageElement < ActiveRecord::Base
    belongs_to :user
    belongs_to :page
    acts_as_list :scope => :page_id
    belongs_to :embeddable, :polymorphic => true

    include Changeable

    # only destroy the embeddable if it isn't referenced by any other page elements
    def before_destroy
      other_related_page_elements = self.embeddable.page_elements.uniq - [self]
      self.embeddable.destroy if other_related_page_elements.empty?
    end

    def dom_id
      "page_element_#{self.id}"
    end
    def teacher_only?
      false
    end
    def parent
      return page
    end
end

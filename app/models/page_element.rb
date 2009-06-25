class PageElement < ActiveRecord::Base
    belongs_to :user
    belongs_to :page
    acts_as_list :scope => :page_id
    belongs_to :embeddable, :polymorphic => true

    # this could work if the finder sql was redone
    # has_one :investigation,
    #   :finder_sql => 'SELECT data_collectors.* FROM data_collectors
    #   INNER JOIN page_elements ON data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "DataCollector"
    #   INNER JOIN pages ON page_elements.page_id = pages.id
    #   WHERE pages.section_id = #{id}'

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
    
    ## Update timestamp of investigation that the page element belongs to
    def update_investigation_timestamp
      page = self.page
      page.update_investigation_timestamp if page
    end

end

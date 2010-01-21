class PageElement < ActiveRecord::Base
    belongs_to :user
    belongs_to :page
    acts_as_list :scope => :page_id
    belongs_to :embeddable, :polymorphic => true

    # this could work if the finder sql was redone
    # has_one :investigation,
    #   :finder_sql => 'SELECT embeddable_data_collectors.* FROM embeddable_data_collectors
    #   INNER JOIN page_elements ON embeddable_data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "Embeddable::DataCollector"
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
    
    def duplicate
      @copy = self.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
      @em = self.embeddable
      
      # let embeddables define their own means to save
      if @em.respond_to? :duplicate
        @copy.embeddable = @em.duplicate
      else
        @copy.embeddable = @em.deep_clone :no_duplicates => true, :never_clone => [:uuid, :updated_at,:created_at]
      end
      
      if @copy.embeddable
        @copy.embeddable.save
      end
      
      @copy.save
      @copy
    end
    
end

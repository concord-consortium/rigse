class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  has_many :page_elements, :order => :position

  has_many :xhtmls, :through => :page_elements, :source => :embeddable, :source_type => 'Xhtml'
  has_many :open_responses, :through => :page_elements, :source => :embeddable, :source_type => 'OpenResponse'
  has_many :multiple_choices, :through => :page_elements, :source => :embeddable, :source_type => 'MultipleChoice'
  has_many :data_collectors, :through => :page_elements, :source => :embeddable, :source_type => 'DataCollector'
  
  acts_as_replicatable
  acts_as_list
  accepts_nested_attributes_for :page_elements, :allow_destroy => true 
  
  default_value_for :position, 1;
  default_value_for :description, "Each new day is a blank page in the diary of your life. The secret of success is in turning that diary into the best story you possibly can."
  default_value_for :name, "empty page"
  
  after_create :add_xhtml
  
  def add_xhtml
    xhtml = Xhtml.create
    xhtml.pages << self
    xhtml.save
  end
  
  
  #
  # return element.id for the component passed in
  # so for example, pass in an xhtml item in, and get back a page_elements object.
  # assumes that this page contains component
  def element_for(component)
    component.page_elements.detect {|pe| pe.page == self }
    # return page_elements.detect { |e| (e.embeddable_type == component.class.name && e.embeddable_id == component.id) }
  end

end

class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :section
  has_many :page_elements, :order => :position, :dependent => :destroy

  has_many :xhtmls, :through => :page_elements, :source => :embeddable, :source_type => 'Xhtml'
  has_many :open_responses, :through => :page_elements, :source => :embeddable, :source_type => 'OpenResponse'
  has_many :multiple_choices, :through => :page_elements, :source => :embeddable, :source_type => 'MultipleChoice'
  has_many :data_collectors, :through => :page_elements, :source => :embeddable, :source_type => 'DataCollector'
  
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable
  acts_as_list
  
  include Changeable
  validates_presence_of :name, :on => :create, :message => "can't be blank"

  accepts_nested_attributes_for :page_elements, :allow_destroy => true 
  
  default_value_for :position, 1;
  default_value_for :name, "untitled page"
  default_value_for :description, "describe the purpose of this page here..."

  # 
  # after_create :add_xhtml
  # 
  # def add_xhtml
  #   if(self.page_elements.size < 1)
  #     xhtml = Xhtml.create
  #     xhtml.pages << self
  #     xhtml.save
  #   end
  # end
  
  #
  # return element.id for the component passed in
  # so for example, pass in an xhtml item in, and get back a page_elements object.
  # assumes that this page contains component.  Because this can cause confusion,
  # if we pass in a page_element we directly return that.
  def element_for(component)
    if component.instance_of? PageElement
      return component
    end
    return component.page_elements.detect {|pe| pe.embeddable.id == component.id }
  end

  def teacher_note
    if teacher_notes[0]
      return teacher_notes[0]
    end
    teacher_notes << TeacherNote.create
    return teacher_notes[0]
  end
end

class Embeddable::LabBookSnapshot < ActiveRecord::Base
  set_table_name "embeddable_lab_book_snapshots"

  
  belongs_to :user
  belongs_to :target_element, :polymorphic => true
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable
  self.extend SearchableModel
  
  send_update_events_to :investigations
  
  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Embeddable::LabBookSnapshot element"
  default_value_for :description, "description ..."
  



  def other_elements_on_page
    results = []
    pages.each do |p|
      results << p.page_elements.map { |elem| elem.embeddable }
    end
    results.flatten!
    results - [self]
  end

  # TODO This targeted_id and self.encode/decode behavior is useful for allowing polymorphic relationships via the web authoring ui... perhaps it should be extracted elsewhere?
  #  self.encode is pretty close to dom_id_for, except that it includes modules in the rendered string
  #  Note: in the otml rendering, you should use render_scoped_reference(lab_book_snapshot.target_element) instead of encode/decode to maintain compatibility with dom_id_for
  def targeted_id
    if target_element
      return Embeddable::LabBookSnapshot.encode(target_element)
    end
    return "none"
  end
  
  def targeted_id=(string)
    self.target_element = Embeddable::LabBookSnapshot.decode(string)
  end
  
  def self.encode(element)
    return "#{element.class.name.underscore}_#{element.id}"
  end
  
  def self.decode(string)
    m = string.match /(.*)_(\d+)/
    if m && m.size == 3
      klass = m[1].classify.constantize
      elem_id = m[2].to_i
      puts klass
      found = klass.find(elem_id)
      puts "==================================== found: #{found}"
      return klass.find(elem_id)
    end
    return nil
  end
  

end

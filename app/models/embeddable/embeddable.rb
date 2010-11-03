class Embeddable::Embeddable < ActiveRecord::Base

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  #def before_save
    #self.name = self.title
  #end
  
  acts_as_replicatable
  include Changeable
  include Cloneable
  
  self.extend SearchableModel

  send_update_events_to :investigations

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

  def activitiies
    acts = []
    self.pages.each do |page|
      act = page.activities
      acts << act if act
    end
  end

end

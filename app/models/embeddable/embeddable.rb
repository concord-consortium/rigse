class Embeddable::Embeddable < ActiveRecord::Base
  self.abstract_class=true
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  #def before_save
    #self.name = self.title
  #end
  
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

  def activitiies
    acts = []
    self.pages.each do |page|
      act = page.activities
      acts << act if act
    end
  end

  def _dis_enable_targets(page)
    results = []
    if page.nil?
      results = self.page_elements
    else
      page_element = self.page_elements.detect{ |elm| elm.page == page}
      (results << page_element) unless page_element.nil?
    end
    results
  end
  
  def enable(page=nil)
    _dis_enable_targets(page).each do |target|
      target.is_enabled = true
      target.save
    end
  end

  def disable(page=nil)
    _dis_enable_targets(page).each do |target|
      target.is_enabled = false
      target.save
    end
  end

  def toggle_enabled(page=nil)
    _dis_enable_targets(page).each do |target|
      if target.is_enabled
        target.is_enabled = false
      else
        target.is_enabled = true
      end
      target.save
    end
  end

end

class Search::SearchMaterial
  
  include ProbeTypesHelper
  
  attr_accessor :material
  attr_accessor :parent_material
  attr_accessor :user
  
  attr_accessor :id
  attr_accessor :model_name
  attr_accessor :title
  attr_accessor :description
  attr_accessor :assign_btn_text
  attr_accessor :icon_image_url
  attr_accessor :activities
  attr_accessor :selected_activities
  attr_accessor :url
  
  attr_accessor :other_data
  
  attr_accessor :activity_list_title
  
  def initialize(material, user)
    self.material = material
    self.user = user
    self.parent_material = self
    
    self.other_data = {
      :grade_span_expectation => nil,
      :grade_span => nil,
      :domain_name => nil,
      :probe_types => nil,
      :required_equipments => nil
    }
    
    self.populateMaterialData
  end
  
  def populateMaterialData
    material = self.material
    user = self.user
    
    
    self.id = material.id
    self.model_name = material.class.name
    self.title = material.full_title
    self.description = material.description
    self.assign_btn_text = "Assign #{self.model_name}"
    self.icon_image_url = "search/#{self.model_name.downcase}.gif"
    self.activities = (material.is_a? ::Investigation) ? material.activities : nil
    self.selected_activities = []
    
    if self.activities
      if user.anonymous?
        self.activities = self.activities.without_teacher_only
      end
      self.selected_activities = self.activities.map{|activity| activity.id}
    end
    
    self.url = nil
    
    
    self.activity_list_title = self.title
    
    self.other_data[:probe_types] = self.probe_types(material)
    self.other_data[:required_equipments] = self.other_data[:probe_types].map { |p| p.name }.join(", ")
    
    if material.is_a? ::Investigation
      
      self.url = {:only_path => false, :controller => 'investigations', :action => 'show', :id => self.id}
      
      self.other_data[:grade_span_expectation] = material.grade_span_expectation
      if self.other_data[:grade_span_expectation]
        self.other_data[:grade_span] = material.grade_span
        self.other_data[:domain_name] = material.domain.name
      end
      
    elsif material.is_a? ::Activity
      
      self.url = {:only_path => false, :controller => 'activities', :action => 'show', :id => self.id}
      
      if material.parent
        parent_material = Search::SearchMaterial.new(material.parent, user)
        
        parent_material.selected_activities = [self.material.id]
        parent_material.assign_btn_text = "Assign Individual Activities"
        
        self.parent_material = parent_material
        
      end
      
    end
  end
  
  
  def get_page_title_and_meta_tags
    
    page_meta = {
      :title => nil,
      :meta_tags => {},
      :open_graph => {}
    }
    
    page_meta[:title] = self.title
    
    meta_tags = page_meta[:meta_tags]
    
    meta_tags[:title] = page_meta[:title]
    meta_tags[:description] = self.description
    if meta_tags[:description].blank?
      meta_tags[:description] = "Check out this great #{self.model_name.downcase} from the Concord Consortium."
    end
    
    open_graph = page_meta[:open_graph]
    
    open_graph[:title] = meta_tags[:title]
    open_graph[:description] = meta_tags[:description]
    open_graph[:type] = 'website'
    open_graph[:url] = self.url
    open_graph[:image] = "/assets/#{self.icon_image_url}"
    
    return page_meta
  end
  
end


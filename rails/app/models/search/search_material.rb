class Search::SearchMaterial

  attr_accessor :material
  attr_accessor :parent_material
  attr_accessor :user

  attr_accessor :id
  attr_accessor :model_name
  attr_accessor :title
  attr_accessor :long_description_for_current_user
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

    self.populateMaterialData
  end

  def populateMaterialData
    material = self.material
    user = self.user


    self.id = material.id
    self.model_name = material.class.name
    self.title = material.full_title
    self.long_description_for_current_user = material.long_description_for_user(user)
    self.assign_btn_text = (material.is_a? ::ExternalActivity) ? "Assign" : "Assign #{material.display_name}"
    self.icon_image_url = material.icon_image || "search/#{self.model_name.downcase}.gif"
    self.activities = (material.respond_to?(:activities)) ? material.activities : nil
    self.selected_activities = []

    if self.activities
      if user.anonymous?
        self.activities = self.activities.without_teacher_only
      end
      self.selected_activities = self.activities.map{|activity| activity.id}
    end

    self.url = nil


    self.activity_list_title = self.title

    if material.is_a? ::Investigation

      self.url = {:only_path => false, :controller => 'investigations', :action => 'show', :id => self.id}

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
    meta_tags[:description] = self.long_description_for_current_user
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

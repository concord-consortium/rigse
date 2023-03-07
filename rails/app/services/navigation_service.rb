class NavItem
  attr_accessor :id
  attr_accessor :label
  attr_accessor :url
  attr_accessor :type
  attr_accessor :onClick
  attr_accessor :popOut
  attr_accessor :sort
  attr_accessor :selected
  attr_accessor :iconName
  attr_accessor :children

  def defaults
    {
      type: NavigationService::LINK_TYPE,
      sort: NavigationService::DEFAULT_SORT
    }
  end

  def initialize(props)
    attributes = self.defaults.merge(props)
    attributes.each { |k,v| instance_variable_set("@#{k}", v) }
  end

  def merge(nav_item)
    props = nav_item.to_h
    props.delete(:children)
    props.each { |k,v| instance_variable_set("@#{k}", v) }
  end
  
  def to_h
    hash = instance_variables.each_with_object({}) do |var, hash|
      if instance_variable_get(var)
        v = instance_variable_get(var)
        hash[var.to_s.delete("@").to_sym] = v
      end
    end
    if @children
      hash[:children] = @children.map { |c| c.to_h }
    end
    hash
  end

end

class NavigationService
  ROOT_SECTION = "__ROOT__"
  ROOT_PATH = "/"
  DEFAULT_SORT = 5
  SECTION_TYPE = "SECTION"
  LINK_TYPE = "LINK"
  attr_accessor :name
  attr_accessor :greeting
  attr_accessor :selected_section
  attr_accessor :links
  attr_accessor :sections

  def initialize(viewHelper, params={})
    @user = params[:user]
    @greeting = params[:greeting] || default_greeting
    @request_path = params[:request_path] || ROOT_PATH
    @selected_section = params[:selected_section] || ROOT_SECTION
    @name = params[:name] || default_name
    @help = params[:help] || default_help
    @root = NavItem.new ({
      id: ROOT_SECTION,
      label: "",
      type: SECTION_TYPE,
      children: []
    })
    @sections = {
      ROOT_SECTION => @root
    }
    @links = []
  end

  def default_name
    "guest"
  end

  def default_greeting
    "Welcome,"
  end

  def default_help
    {
      label: "help",
      url: "/help",
      id: "/help",
      type: LINK_TYPE,
      popOut: true
    }
  end

  def parent_id_for(id)
    parent_paths =  id.split("/")
    if parent_paths.size > 0
      parent_id = id.split("/")[0...-1].join("/")
    end
    if(parent_id.blank?)
      parent_id = ROOT_SECTION
    end
    parent_id
  end

  def parent_for(id)
    return @sections[parent_id_for(id)]
  end

  def remove_item(id)
    parent = parent_for(id)
    if parent
      parent.children.reject! {|i| i.id == id}
      parent.children.sort_by! { |a| a.sort }
    end
    @sections.delete(id)
    @links.delete(id)
  end

  def add_link(item)
    if link = @links.find {|l| l.id == item.id}
      link.merge(item)
    else
      link = item
      @links.push item
    end
    parent = parent_for(link.id)
    parent_id = parent_id_for(link.id)
    if !parent
      parent = add_item({type: SECTION_TYPE, id: parent_id})
    end
    unless parent.children.find { |c| c.id == link.id }
      parent.children.push link
      parent.children.sort_by! { |a| a.sort ||0}
    end
    return link
  end

  def add_section(item)
    if section = @sections[item.id]
      section.merge(item)
    else
      section = item
      section.children ||= []
      section.label ||= item.id.split("/").last.capitalize
      @sections[item.id] = item
    end
    parent = parent_for(section.id)
    parent_id = parent_id_for(section.id)
    if !parent
      parent = add_item({type: SECTION_TYPE, id: parent_id})
    end
    unless parent.children.find { |c| c.id == section.id }
      parent.children.push section
    end
    return section
  end
  # id: "/",
  # label: ""
  # sort: 1,
  # type: "section",
  # children: []
  def add_item(item_spec)
    item = NavItem.new(item_spec)
    unless(item.type)
      item.type = item.url ? LINK_TYPE : SECTION_TYPE
    end
    case item.type
    when LINK_TYPE
      add_link(item)
    when SECTION_TYPE
      add_section(item)
    end
  end

  def item_to_hash(item)
    return_hash = item.to_h
    if item.children
      return_hash[:children] = item.children.map { |c| item_to_hash(c) }
    end
    if item.url
      return_hash[:url] = item.url
    end
    return_hash
  end

  def to_hash
    {
      name: @name,
      help: @help,
      greeting: @greeting,
      selected_section: @selected_section,
      request_path: @request_path,
      links: @root.children.map { |section| item_to_hash(section) }
    }
  end

  def update_selection
    if @request_path == ROOT_PATH
      @selected_section = ROOT_SECTION
    end
    @links.each do |link|
      if @request_path =~ %r[#{link.url}$]
        link.selected = true
        @selected_section = link.id || ROOT_SECTION
      end
    end
  end

  def to_json
    to_hash.to_json
  end

end

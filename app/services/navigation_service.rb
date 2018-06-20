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
  attr_accessor :className
  attr_accessor :target
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

  def to_h
    hash = instance_variables.each_with_object({}) {|var,hash| hash[var.to_s.delete("@").to_sym] = instance_variable_get(var) }
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
  SELECTED_LINK_CLASS = "link-selected"
  SELECTED_SECTION_CLASS = "in-selected-section"
  NO_ICON_CLASS = "no-icon"
  POPOUT_CLASS = "pop-out"
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
    parent_id = id.split("/")[0...-1].join("/")
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
    self.guess_selection
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
    parent = parent_for(item.id)
    parent_id= parent_id_for(item.id)
    default_section_params = {
      id: parent_id,
      label: parent_id,
      sort: DEFAULT_SORT,
      type: SECTION_TYPE,
      children: []
    }
    if !parent
      parent = add_item(default_section_params)
    end

    if item.type == SECTION_TYPE
      item.children ||= []
      @sections[item.id] = item
    elsif item.url
      @links.push item
    end

    parent.children.push item
    parent.children.sort_by! { |a| a.sort }
    self.guess_selection
    return item
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

  def guess_selection
    if @request_path == ROOT_PATH
      @selected_section = ROOT_SECTION
    end
    @links.each do |link|
      if @request_path =~ %r[#{link.url}$]
        link.selected = true
        @selected_section = link.id || ROOT_SECTION
      end
    end
    @links.each do |link|
      link.target = '_blank' if link.popOut
      link.className  = ""
      link.className << " #{SELECTED_LINK_CLASS}" if link.selected
      link.className << " #{NO_ICON_CLASS}" unless link.iconName
      link.className << " #{POPOUT_CLASS}" if link.popOut
      if @selected_section != ROOT_SECTION
        link.className << " #{SELECTED_SECTION_CLASS}" if link.id == @selected_section
      end
    end
  end

  def to_json
    to_hash.to_json
  end

end
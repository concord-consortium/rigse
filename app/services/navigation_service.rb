require 'ostruct'


class Section
  attr_accessor :path
  attr_accessor :label
  attr_accessor :children

  def sortChildren

  end

  def addChild(linkOrSection)
    children.push linkOrSection
    self.sortChildren()
  end

end

class NavigationService
  ROOT_SECTION = "__NONE__"
  ROOT_PATH = "/"
  DEFAULT_SORT = 5
  SECTION_TYPE = "SECTION"
  SELECTED_LINK_CLASS = "link-selected"
  SELECTED_SECTION_CLASS = "in-selected-section"
  NO_ICON_CLASS = "no-icon"
  POPOUT_CLASS = "pop-out"
  attr_accessor :name
  attr_accessor :greeting
  attr_accessor :selected_section
  attr_accessor :links

  def initialize(viewHelper, params={})
    @user = params[:user]
    @greeting = params[:greeting] || default_greeting
    @request_path = params[:request_path] || ROOT_PATH
    @selected_section = params[:selected_section] || ROOT_SECTION
    @name = params[:name] || default_name
    @help = params[:help] || default_help
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
      popOut: true
    }
  end


  # id: "/",
  # label: ""
  # sort: 1,
  # type: "section",
  # children: []
  def add_item(item_spec)
    item = OpenStruct.new(item_spec)
    parent_id = item.id.split("/")[0...-1].join("/")
    if(parent_id.blank?)
      parent_id = ROOT_SECTION
    end
    parent = @sections.find { |item| item.id == parent_id }
    parent ||= add_item({
      id: parent_id,
      label: parent_id,
      sort: DEFAULT_SORT,
      type: SECTION,
      children: []
    })

    if item.type == SECTION_TYPE
      item.chidlren ||= []
      @sections.push item
      @sections.sort! { |a,b| a.sort <=> b.sort }
    end

    parent.children.push item
    parent.children.sort! { |a,b| a.sort <=> b.sort }

    return item
  end

  def add_link(link_spec)
    link = OpenStruct.new(link_spec)
    link.section ||= ROOT_SECTION
    section = find_or_create_parent(link.selection)
    @links.push link
    guess_selection
  end

  def sectionFor(linkHash)
    return linkHash[:section]
  end

  def makeSections(links)
    @sections ||={}
    @sections.push(ROOT_SECTION => {})
    sectionPaths = @links.map do |link|
      section = link.section
      label = section.split("/")
      parent_id = section.split("/")[0...-1].join("/")

      OpenStruct.new({
        id: section,
        label: label,
        parent_id: parent_id,
        ChangeJ2seFieldnameMavenJnlpVersionedJnlp
      })
    end

    @links.each do |link|

    end
  end

  def to_hash
    {
      name: @name,
      help: @help,
      greeting: @greeting,
      selected_section: @selected_section,
      request_path: @request_path,
      links: @links
        .map { |l| l.to_h }
        .group_by { |h| self.sectionFor(h)}
    }
  end

  def guess_selection
    if @request_path == ROOT_PATH
      @selected_section = ROOT_SECTION
    end
    @links.each do |link|
      if @request_path =~ %r[#{link.url}$]
        link.selected = true
        @selected_section = link.section || ROOT_SECTION
      end
    end
    @links.each do |link|
      link.target = '_blank' if link.popOut
      link.className  = ""
      link.className << " #{SELECTED_LINK_CLASS}" if link.selected
      link.className << " #{NO_ICON_CLASS}" unless link.iconName
      link.className << " #{POPOUT_CLASS}" if link.popOut
      if @selected_section != ROOT_SECTION
        link.className << " #{SELECTED_SECTION_CLASS}" if link.section == @selected_section
      end
    end
  end

  def to_json
    to_hash.to_json
  end

end
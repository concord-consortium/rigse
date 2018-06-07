
module NavigationHelper

  private
  def show_help_link
    return false unless current_settings
    current_settings.help_type == 'external url' || current_settings.help_type == 'help custom html'
  end

  def show_favorites_link
    is_teacher
  end

  def is_student
    current_visitor.portal_student || false
  end

  def is_teacher
    current_visitor.portal_teacher || false
  end

  def show_admin_links
    current_visitor.has_role?('admin', 'manager','researcher') ||
    current_visitor.is_project_admin? ||
    current_visitor.is_project_researcher?
  end

  def show_switch_user_link
    # TODO: @original_user isn't available to us probably...
    @original_user && @original_user != current_visitor
  end

  def help_link_params
    {
      label: 'Help',
      url: '/help',
      popOut: true,
      iconName:'icon-search',
      className: 'help-link'
    }
  end

  def preference_link_params
    {
      label: 'Settings',
      url: preferences_user_path(current_visitor),
      iconName: 'icon-settings'
    }
  end

  def favorite_link_params
    {
      label: 'Favorites',
      url: favorites_user_path(current_visitor),
      iconName: 'icon-favorite'
    }
  end

  def admin_link_params
    {
      label: 'Admin',
      url: admin_path
    }
  end

  def clazz_label(clazz)
    if clazz.section
      "#{clazz.name} (#{clazz.section})"
    else
      clazz.name
    end
  end

  def clazz_links_for_student
    clazzes = current_visitor.portal_student.clazzes
    clazz_links = []
    clazzes.each do |clazz|
      clazz_links << {section: "classes", label: clazz_label(clazz), url: url_for(clazz) }
    end
    clazz_links
  end

  def clazz_links_for_teacher
    # TODO Omit inactive classes.
    clazzes = current_visitor.portal_teacher.teacher_clazzes.map { |c| c.clazz }
    clazz_links = []
    clazzes.each do |clazz|
      section_name = "Classes/#{clazz_label(clazz)}"
      clazz_links << {
        section: section_name,
        label: "Assignments",
        url: url_for([:materials, clazz])
      }
      clazz_links << {
        section: section_name,
        label: "Student Roster",
        url: url_for([:roster, clazz])
      }
      clazz_links << {
        section: section_name,
        label: "Class Setup",
        url: url_for([:edit, clazz])
      }
      clazz_links << {
        section: section_name,
        label: "Full Status",
        url: url_for([:fullstatus, clazz])
      }
      clazz_links << {
        section: section_name,
        label: "Links",
        url: url_for([clazz, :bookmarks])
      }
    end
    clazz_links << {
      section: "Classes",
      label: "Add Class",
      url: new_portal_clazz_path
    }
    clazz_links
  end

  def clazz_links
    if is_teacher
      clazz_links_for_teacher
    elsif is_student
      clazz_links_for_student
    else
      []
    end
  end


  def switch_user_link
    # TODO: Make an API to switch users.
    {label: "Switch Back", url: "userse/switch" }
  end


  def itsi_links
    section_name = "Resources"
    [
      {
        section: section_name,
        label: 'activities',
        url: '/itsi',
        popOut: false
      },
      {
        section: section_name,
        label: 'interactives',
        url: '/interactives',
        popOut: true
      },
      {
        section: section_name,
        label: 'images',
        url: '/images',
        popOut: true
      },
      {
        section: section_name,
        label: 'Teacher Guides',
        url: 'https://guides.itsi.concord.org/',
        popOut: true
      },
      {
        section: section_name,
        label: 'Careersight',
        url: 'https://careersight.concord.org/',
        popOut: true
      },
      {
        section: section_name,
        label: 'Probesight',
        url: 'https://probesight.concord.org/',
        popOut: true
      },
      {
        section: section_name,
        label: 'Schoology',
        url: 'https://www.schoology.com/',
        popOut: true
      }
    ]
  end


  public
  def navigation_service(params={})
    _params = {
      name: current_visitor.name,
      request_path: request.path,
    }
    service =  NavigationService.new(self, params.merge(_params))

    if show_help_link
      service.add_link help_link_params
    end

    service.add_link preference_link_params

    if show_favorites_link
      service.add_link favorite_link_params
    end

    if show_admin_links
      service.add_link admin_link_params
    end

    if show_switch_user_link
      service.add_link switch_user_link
    end


    clazz_links.each {|clazz_link| service.add_link clazz_link}
    itsi_links.each { |link| service.add_link link}
    return service
  end


end
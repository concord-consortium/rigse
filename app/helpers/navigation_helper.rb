
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
      id: '/help',
      label: 'Help',
      url: '/help',
      popOut: true,
      iconName:'icon-search',
      className: 'help-link'
    }
  end

  def preference_link_params
    {
      id: '/settings',
      label: 'Settings',
      url: preferences_user_path(current_visitor),
      iconName: 'icon-settings'
    }
  end

  def favorite_link_params
    {
      id: '/favorites',
      label: 'Favorites',
      url: favorites_user_path(current_visitor),
      iconName: 'icon-favorite'
    }
  end

  def admin_link_params
    {
      id: '/admin',
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
    clazz_links = [
      id: "/classes",
      label: "Classes",
      type: NavigationService::SECTION_TYPE
    ]
    clazzes.each do |clazz|
      clazz_links << {
        id: "/classes/#{clazz.id}",
        label: clazz_label(clazz),
        url: url_for(clazz) }
    end
    clazz_links
  end

  def clazz_links_for_teacher
    # TODO Omit inactive classes.
    clazzes = current_visitor.portal_teacher.teacher_clazzes.map { |c| c.clazz }
    clazz_links = [
      {
        id: "/classes",
        label: "clazz_label(clazz)",
        type: NavigationService::SECTION_TYPE
      }
    ]
    clazzes.each do |clazz|
      section_id = "/classes/#{clazz.id}"
      clazz_links << {
        id: section_id,
        label: "#{clazz_label(clazz)}",
        type: NavigationService::SECTION_TYPE
      }
      clazz_links << {
        id: "#{section_id}/assignments",
        label: "Assignments",
        url: url_for([:materials, clazz])
      }
      clazz_links << {
        id: "#{section_id}/roster",
        label: "Student Roster",
        url: url_for([:roster, clazz])
      }
      clazz_links << {
        id: "#{section_id}/setup",
        label: "Class Setup",
        url: url_for([:edit, clazz])
      }
      clazz_links << {
        id: "#{section_id}/status",
        label: "Full Status",
        url: url_for([:fullstatus, clazz])
      }
      clazz_links << {
        id: "#{section_id}/links",
        label: "Links",
        url: url_for([clazz, :bookmarks])
      }
    end
    clazz_links << {
      id: "/classes/add",
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
        id: '/resources/activities',
        label: 'activities',
        url: '/itsi',
        popOut: false
      },
      {
        id: '/resources/interactives',
        label: 'interactives',
        url: '/interactives',
        popOut: true
      },
      {
        id: '/resources/images',
        label: 'images',
        url: '/images',
        popOut: true
      },
      {
        id: '/resources/guides',
        label: 'Teacher Guides',
        url: 'https://guides.itsi.concord.org/',
        popOut: true
      },
      {
        id: '/resources/careers',
        label: 'Careersight',
        url: 'https://careersight.concord.org/',
        popOut: true
      },
      {
        id: '/resources/probes',
        label: 'Probesight',
        url: 'https://probesight.concord.org/',
        popOut: true
      },
      {
        id: '/resources/schoology',
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
      service.add_item help_link_params
    end

    service.add_item preference_link_params

    if show_favorites_link
      service.add_item favorite_link_params
    end

    if show_admin_links
      service.add_item admin_link_params
    end

    if show_switch_user_link
      service.add_item switch_user_link
    end


    clazz_links.each {|clazz_link| service.add_item clazz_link}
    itsi_links.each { |link| service.add_item link}
    return service
  end


end
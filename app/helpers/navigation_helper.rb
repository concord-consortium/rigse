
module NavigationHelper

  private

  def nav_label(key)
    return I18n.t key, scope: :Navigation, default: key.gsub(/_/, "").capitalize
  end

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

  def teaches_classes
    return is_teacher &&  (current_visitor.portal_teacher.clazzes.size > 0)
  end

  def show_admin_links
    current_visitor.has_role?('admin', 'manager','researcher') ||
    current_visitor.is_project_admin? ||
    current_visitor.is_project_researcher?
  end

  def show_switch_user_link
    @original_user && @original_user != current_visitor
  end

  def getting_started_params
    if is_teacher && !teaches_classes
      return {
        id: '/getting_started',
        label: nav_label('getting_started'),
        url: getting_started_path
      }
    else
      false
    end
  end

  def recent_update_params
    if teaches_classes
      {
        id: '/recent_updates',
        label: nav_label('recent_updates'),
        url: recent_activity_path
      }
    else
      false
    end
  end

  def help_link_params
    if show_help_link
      {
        id: '/help',
        label: nav_label('Help'),
        url: '/help',
        small: true,
        sort: -1,
        iconName:'icon-search',
      }
    else
      false
    end
  end

  def preference_link_params
    if current_visitor.anonymous?
      nil
    else
      {
        id: '/settings',
        label: nav_label('settings'),
        url: preferences_user_path(current_visitor),
        iconName: 'icon-settings',
        sort: 0,
        small: true
      }
    end
  end

  def favorite_link_params
    if is_teacher
      {
        id: '/favorites',
        label: nav_label('favorites'),
        url: favorites_user_path(current_visitor),
        iconName: 'icon-favorite',
        sort: 1,
        small: true
      }
    else
      false
    end
  end

  def admin_link_params
    {
      id: '/admin',
      label: nav_label('admin'),
      url: admin_path,
      sort: 2
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
      clazz_links << {
        id: "/#{clazz.id}",
        label: clazz_label(clazz),
        url: url_for(clazz)
      }
    end
    clazz_links
  end

  def clazz_links_for_teacher
    # TODO Omit inactive classes?
    clazzes = current_visitor.portal_teacher.teacher_clazzes.map { |c| c.clazz }
    clazz_links = [
      {
        id: "/classes",
        label: nav_label("classes"),
        type: NavigationService::SECTION_TYPE,
        sort: 4
      }
    ]
    clazzes.each do |clazz|
      section_id = "/classes/#{clazz.id}"
      clazz_links << {
        id: section_id,
        label: clazz_label(clazz),
        type: NavigationService::SECTION_TYPE
      }
      clazz_links << {
        id: "#{section_id}/assignments",
        label: nav_label("assignments"),
        url: url_for([:materials, clazz])
      }
      clazz_links << {
        id: "#{section_id}/roster",
        label: nav_label("student_roster"),
        url: url_for([:roster, clazz])
      }
      clazz_links << {
        id: "#{section_id}/setup",
        label: nav_label("class_setup"),
        url: url_for([:edit, clazz])
      }
      # TODO: Delete this one, its not used any more:
      # clazz_links << {
      #   id: "#{section_id}/status",
      #   label: nav_label("full_status"),
      #   url: url_for([:fullstatus, clazz])
      # }
      clazz_links << {
        id: "#{section_id}/links",
        label: nav_label("links"),
        url: url_for([clazz, :bookmarks])
      }
    end
    clazz_links << {
      id: "/classes/add",
      label: "Add Class",
      divider: true,
      url: new_portal_clazz_path,
      sort: 10
    }
    clazz_links << {
      id: "/classes/manage",
      label: "Manage Classes",
      url: manage_portal_clazzes_url,
      sort: 11
      # link_to 'Manage Classes', manage_portal_clazzes_url, :class=>"pie", :id=>"btn_manage_classes"
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

  def project_link(project_link_spec)
    {
      id: project_link_spec.link_id || "/resources/#{project_link_spec.name}",
      label: project_link_spec.name,
      url: project_link_spec.href,
      popOut: project_link_spec.pop_out,
      sort: project_link_spec.position
    }
  end

  def project_links
    links = []
    if current_visitor.has_role?('admin', 'manager', 'researcher') || current_visitor.portal_teacher
      links = current_visitor.projects.map { |p| p.links }
      links.flatten!
    end
    links.map! { |l| project_link l }
    if links.size > 0
      links.unshift({
        id: "/resources",
        label: nav_label('resources'),
        type: NavigationService::SECTION_TYPE,
        sort: 5
      })
    else
      []
    end
  end

  def switch_user_link
    {
      label: nav_label('switch_back'),
      id: "switch",
      url: switch_back_user_path(current_visitor),
      sort: 2
    }
  end


  public
  def navigation_service(params={})
    _params = {
      name: current_visitor.name,
      request_path: request.path,
    }

    service =  NavigationService.new(self, params.merge(_params))

    service.add_item help_link_params if help_link_params

    service.add_item getting_started_params if getting_started_params
    service.add_item recent_update_params if recent_update_params

    if show_admin_links
      service.add_item admin_link_params
    end

    if show_switch_user_link
      service.add_item switch_user_link
    end

    clazz_links.each {|clazz_link| service.add_item clazz_link}
    project_links.each { |link| service.add_item link}

    service.add_item preference_link_params if preference_link_params
    service.add_item favorite_link_params if favorite_link_params
    # after all the links have been added
    # detect which link we are on.
    service.update_selection()
    return service
  end


end
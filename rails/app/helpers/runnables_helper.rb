module RunnablesHelper

  def use_adhoc_workgroups?
    return APP_CONFIG[:use_adhoc_workgroups]
  end

  def display_workgroups_run_link?(offering)
    runnable = offering.runnable
    return runnable.allow_collaboration if runnable.respond_to?(:allow_collaboration)
    return false
  end

  def display_status_updates?(offering)
    return false
  end

  # TODO: rename and make more general
  def student_run_button_css(offering,_classes=[])
    classes = _classes.dup
    classes << "button"
    classes << "run" if display_status_updates?(offering)
    classes << "disabled" if offering.locked
    classes.join(" ")
  end

  def student_run_buttons(offering,opts={})
    default_solo_label = display_workgroups_run_link?(offering) ? "Run by Myself" : "Run"
    solo_label      = opts[:solo_text]  || default_solo_label
    group_label     = opts[:group_label]|| "Run with Other Students"
    options         = popup_options_for(offering)
    options[:href]  = !offering.locked ? run_url_for(offering) : "javascript:void(0)"
    options[:class] = student_run_button_css(offering, ["solo"])
    # Disable button for 10 seconds after click, to prevent accidental double-clicks
    options[:onclick] = "if (this.classList.contains('disabled')) { event.preventDefault(); } else { this.classList.add('disabled'); setTimeout(() => { this.classList.remove('disabled'); }, 10000); }"

    capture_haml do
      haml_tag :a, options do
        haml_concat solo_label
      end
      if display_workgroups_run_link?(offering)
        options[:class] = student_run_button_css(offering, ["in_group"])
        options[:label] = group_label
        options[:offeringId] = offering.id
        span_id = "run-with-collaborators-button-#{offering.id}"
        haml_tag :span, {:id => span_id}
        haml_tag :script do
          haml_concat "PortalComponents.renderRunWithCollaborators(#{options.to_json}, '#{span_id}');".html_safe
        end
      end
    end
  end

  def runnable_type_label(component)

    runnable = component.is_a?(Portal::Offering) ? component.runnable : component

    if  runnable.is_a?(ExternalActivity) &&
        runnable.respond_to?(:material_type) &&
        !runnable.material_type.nil?

        return I18n.t(runnable.material_type.to_s.underscore.to_sym).titleize
    end

    return runnable.class.display_name
  end

  def title_text(component, verb, run_as)
    text = "#{verb.capitalize} the #{runnable_type_label(component)}: '#{component.name}' as a #{run_as}."
    text
  end

  def updated_time_text(thing)
    if(thing.respond_to? :updated_at)
      return thing.updated_at
    elsif(thing.respond_to? :created_at)
      return thing.created_at
    end
    return ""
  end

  def preview_params(user, default_params = {})
    p = default_params.clone
    if user && user.portal_teacher
      p[:logging] = true
    end
    p
  end

  def run_url_for(component, params = {}, format = nil)
    if component.instance_of? Interactive
      return component.url
    end

    format ||= component.run_format

    params[:format] = format
    if component.kind_of?(Portal::Offering)
      # the user id is added to this url to make the url be unique for each user
      # the user id is not actually used to generate the response or authorize it
      # route: portal/offerings#show {:id=>/\d+/, :user_id=>/\d+/}
      user_portal_offering_url(current_visitor, component, params)
    else
      unless component.instance_of? ExternalActivity
        raise StandardError, "Bad runnable component #{component.class}"
      end
      polymorphic_url(component, params)
    end
  end

  def popup_options_for(component,_options={})
    options = _options.dup
    if component.is_a?(ExternalActivity)
      options[:target] = '_blank' if component.popup
    elsif component.is_a?(Portal::Offering) && component.external_activity?
      options[:target] = '_blank' if component.runnable.popup
    end
    return options
  end

  def x_button_for(component, verb, image = verb, params = {}, run_as = nil)

    unless run_as
      run_as = case component
      when ExternalActivity then ExternalActivity.display_name
      end
    end

    classes = "run_link rollover"
    if component.is_a?(Portal::Offering) && !(component.external_activity?)
      classes << ' offering'
    end
    options = {
      :class => classes,
      :title => title_text(component, verb, run_as)
    }
    options = popup_options_for(component,options)
    link_button("#{image}.png",  run_url_for(component, params), options)
  end

  def x_link_for(component, verb, as_name = nil, params = {})
    link_text = params.delete(:link_text) || "#{verb} "
    url = run_url_for(component, params, params.delete(:format))

    run_type = case component
    when ExternalActivity then ExternalActivity.display_name
    end

    title = title_text(component, verb, run_type)

    link_text << " as #{as_name}" if as_name

    html_options=popup_options_for(component)
    case component
    when Portal::Offering
      if component.external_activity?
        html_options[:class] = 'run_link'
      else
        html_options[:class] = 'run_link offering'
      end
    when ExternalActivity
    else
      html_options[:title] = title
    end

    if params[:no_button]
      link_to(link_text, url, html_options)
    else
      x_button_for(component, verb, verb, params) + link_to(link_text, url, html_options)
    end
  end

  def preview_button_for(component, url_params = nil, img = "preview.png", run_as = nil)
    x_button_for(component, "preview")
  end

  def preview_link_for(component, as_name = nil, params = {})
    x_link_for(component, "preview", as_name, params)
  end

  def offering_link_for(offering, as_name = nil, params = {})
    x_link_for(offering, "run", as_name, params)
  end

end

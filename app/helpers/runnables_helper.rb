include OtmlHelper
include JnlpHelper
include Clipboard

module RunnablesHelper
  def title_text(component, verb, run_as)
    text = "#{verb.capitalize} the #{component.class.display_name}: '#{component.name}' as a #{run_as}."
    if component.is_a? JnlpLaunchable
      text << " The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
    end
    text
  end

  def run_url_for(component, params = {}, format = nil)
    format ||= component.run_format

    params.update(current_user.extra_params)
    polymorphic_url(component, :format => format, :params => params)
  end

  def run_button_for(component)
    x_button_for(component, "run")
  end

  def x_button_for(component, verb, image = verb, params = {}, run_as = nil)
    run_url = params[:run_url] || run_url_for(component, params)
    unless run_as
      run_as = case component
      when JnlpLaunchable   then "Java Web Start application"
      when ExternalActivity then "External Activity"
      end
    end

    classes = "run_link rollover"
    if component.is_a? Portal::Offering
      classes << ' offering'
    end
    options = {
      :class => classes,
      :title => title_text(component, verb, run_as)
    }
    if component.is_a?(ExternalActivity)
      options[:popup] = component.popup
    elsif component.is_a?(Portal::Offering) && component.runnable.is_a?(ExternalActivity)
      options[:popup] = component.runnable.popup
    end
    link_button("#{image}.png", run_url, options)
  end

  def x_link_for(component, verb, as_name = nil, params = {})
    link_text = params.delete(:link_text) || "#{verb} "
    url = run_url_for(component, params)
    
    run_type = case component
    when JnlpLaunchable   then "Java Web Start application"
    when ExternalActivity then "External Activity"
    end
    
    title = title_text(component, verb, run_type)

    link_text << " as #{as_name}" if as_name

    html_options={}
    case component
    when Portal::Offering
      html_options[:class] = 'offering'
      html_options[:popup] = component.runnable.popup if component.runnable.kind_of?(ExternalActivity)
    when ExternalActivity
      html_options[:popup] = component.popup
    else
      html_options[:title] = title
    end

    if params[:no_button]
      link_to(link_text, url, html_options)
    else
      x_button_for(component, verb, verb, :run_url => url) + link_to(link_text, url, html_options)
    end
  end

  def preview_button_for(component, url_params = nil, img = "preview.png", run_as = nil)
    x_button_for(component, "preview")
  end

  def teacher_preview_button_for(component)
    x_button_for(component, "preview", "teacher_preview", {:teacher_mode => true}, "Teacher")
  end

  def preview_link_for(component, as_name = nil, params = {})
    x_link_for(component, "preview", as_name, params)
  end

  def offering_link_for(offering, as_name = nil, params = {})
    if offering.resource_page?
      link_to "View #{offering.name}", offering.runnable
    else
      x_link_for(offering, "run", as_name, params)
    end
  end

  def run_link_for(component, as_name = nil, params = {})
    if component.kind_of?(Portal::Offering)
      offering_link_for(component, nil, {:link_text => "run #{component.name}"})
    else
      x_link_for(component, "run", as_name, params)
    end
  end
end

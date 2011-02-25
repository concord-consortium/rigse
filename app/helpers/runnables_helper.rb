include OtmlHelper
include JnlpHelper
include Clipboard

module RunnablesHelper
  def title_text(component, verb, run_as)
    "#{verb.capitalize} the #{component.class.display_name}: '#{component.name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def run_url_for(component, params = {}, format = :jnlp)
    runnable = component.kind_of?(Portal::Offering) ? component.runnable : component
    format = APP_CONFIG[:runnable_mime_type] unless runnable.is_a? JnlpLaunchable

    params.update(current_user.extra_params)
    polymorphic_url(component, :format => format, :params => params)
  end

  def run_button_for(component)
    x_button_for(component, "run")
  end

  def x_button_for(component, verb, image = verb, params = {}, run_as = "Java Web Start application")
    link_button("#{image}.png",  run_url_for(component, params),
                :class => "run_link rollover",
                :title => title_text(component, verb, run_as))
  end

  def x_link_for(component, verb, as_name = nil, params = {})
    link_text = params.delete(:link_text) || "#{verb} "
    url = run_url_for(component, params)
    title = title_text(component, verb, "Java Web Start application")

    link_text << " as #{as_name}" if as_name

    html_options={}

    if component.is_a? JnlpLaunchable
      html_options[:popup] = true
    else
      html_options[:title] = title
    end

    x_button_for(component, verb) + link_to(link_text, url, html_options)
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
      link_to "View #{offering.name}", offering.runnable, :target => '_blank'
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

include OtmlHelper
include JnlpHelper
include Clipboard

module RunnablesHelper
  def run_text(display_name, component_name, run_as)
    "Run the #{display_name}: '#{component_name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def preview_text(display_name, component_name, run_as)
    "Preview the #{display_name}: '#{component_name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def run_button_for(component)
    url = polymorphic_url(component, :format => :jnlp, :params => current_user.extra_params)
    link_button("run.png",  url,
                :class => "run_link rollover",
                :title => run_text(component.class.display_name, component.name, "Java Web Start application"))
  end

  def preview_button_for(component)
    url = polymorphic_url(component, :format => :jnlp, :params => current_user.extra_params)
    link_button("preview.png",  url,
                :class => "run_link rollover",
                :title => preview_text(component.class.display_name, component.name, "Java Web Start application"))
  end

  def teacher_preview_button_for(component)
    url_params = current_user.extra_params
    url_params[:teacher_mode] = true
    url = polymorphic_url(component, :format => :jnlp, :params => url_params)
    link_button("teacher_preview.png",  url,
                :class => "run_link rollover",
                :title => preview_text(component.class.display_name, component.name, "Teacher"))
  end

  def preview_link_for(component, as_name=nil, params={})
    params.update(current_user.extra_params)
    link_text = params.delete(:link_text) || "preview "

    if as_name
      link_text << " as #{as_name}"
    end

    url = polymorphic_url(component, :format => :jnlp, :params => params)
    preview_button_for(component) +
      link_to(link_text, url,
              :class => "run_link",
              :title => preview_text(component.class.display_name, component.name, "Java Web Start application"))
  end

  def run_link_for(component, as_name=nil, params={})
    params.update(current_user.extra_params)
    link_text = params.delete(:link_text) || "run "

    if as_name
      link_text << " as #{as_name}"
    end

    if NOT_USING_JNLPS
      url = polymorphic_url(component, :format => APP_CONFIG[:runnable_mime_type], :params => params)
    else
      url = polymorphic_url(component, :format => :jnlp, :params => params)
    end

    if NOT_USING_JNLPS
      run_button_for(component) + link_to(link_text, url, :popup => true)
    else
      run_button_for(component) +
        link_to(link_text, url,
                :class => 'run_link',
                :title => run_text(component.class.display_name, component.name, "Java Web Start application"))
    end
  end
end

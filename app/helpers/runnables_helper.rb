include OtmlHelper
include JnlpHelper
include Clipboard

module RunnablesHelper
  def run_text(component, run_as = "Java Web Start application")
    "Run the #{component.class.display_name}: '#{component.name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def preview_text(component, run_as = "Java Web Start application")
    "Preview the #{component.class.display_name}: '#{component.name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def run_button_for(component)
    url = polymorphic_url(component, :format => :jnlp, :params => current_user.extra_params)
    link_button("run.png",  url,
                :class => "run_link rollover",
                :title => run_text(component))
  end

  def preview_button_for(component, url_params = nil, img = "preview.png", run_as = nil)
    unless url_params
      url_params = current_user.extra_params
    end

    if run_as
      title = preview_text(component, run_as)
    else
      title = preview_text(component)
    end

    url = polymorphic_url(component, :format => :jnlp, :params => url_params)
    link_button(img,  url,
                :class => "run_link rollover",
                :title => title)
  end

  def teacher_preview_button_for(component)
    url_params = current_user.extra_params
    url_params[:teacher_mode] = true
    preview_button_for(component, url_params, "teacher_preview.png", "Teacher")
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
              :title => preview_text(component))
  end

  def run_link_for(component, as_name=nil, params={})
    params.update(current_user.extra_params)
    link_text = params.delete(:link_text) || "run "

    if as_name
      link_text << " as #{as_name}"
    end

    if NOT_USING_JNLPS
      url = polymorphic_url(component, :format => APP_CONFIG[:runnable_mime_type], :params => params)
      run_button_for(component) + link_to(link_text, url, :popup => true)
    else
      url = polymorphic_url(component, :format => :jnlp, :params => params)
      run_button_for(component) +
        link_to(link_text, url,
                :class => 'run_link',
                :title => run_text(component))
    end
  end
end

include OtmlHelper
include JnlpHelper
include Clipboard

module RunnablesHelper
  def title_text(component, verb, run_as)
    "#{verb.capitalize} the #{component.class.display_name}: '#{component.name}' as a #{run_as}. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive."
  end

  def x_button_for(component, verb, image = verb, params = {}, run_as = "Java Web Start application")
    link_button("#{image}.png",  run_url_for(component, params),
                #:class   => "run_link rollover",
                :class   => "rollover",
                :title   => title_text(component, verb, run_as),
                :onclick => "show_mac_alert($('launch_warning'),false);")
  end

  def x_link_for(component, verb, as_name = nil, params = {})
    link_text = params.delete(:link_text) || "#{verb} "
    url = run_url_for(component, params)
    title = title_text(component, verb, "Java Web Start application")

    link_text << " as #{as_name}" if as_name

    html_options={:onclick => "show_mac_alert($('launch_warning'),false);"}

    if NOT_USING_JNLPS
      html_options[:popup] = true
    else
      html_options[:title] = title
    end

    x_button_for(component, verb) + link_to(link_text, url, html_options)
  end

  def run_url_for(component, params = {}, format = :jnlp)
    format = APP_CONFIG[:runnable_mime_type] if NOT_USING_JNLPS

    params.update(current_user.extra_params)
    polymorphic_url(component, :format => format, :params => params)
  end

  def run_button_for(component)
    x_button_for(component, "run")
    #name = component.name
    #users_params = current_user.extra_params
    #if NOT_USING_JNLPS
      #url = polymorphic_url(component, :format => APP_CONFIG[:runnable_mime_type])
      #link_button("preview.png",  url, :title => "Run the #{component.class.display_name}: '#{name}'.", :popup => true)
    #else
      #url = polymorphic_url(component, :format => :jnlp, :params => current_user.extra_params)
      #link_button("preview.png",  url,
                  #:title => "Run the #{component.class.display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.",
                  #:onclick => "show_mac_alert($('launch_warning'),false);")
    #end
  end

  def preview_button_for(component)
    x_button_for(component, "preview")
    #name = component.name
    #if NOT_USING_JNLPS
      #url = polymorphic_url(component, :format => APP_CONFIG[:runnable_mime_type])
      #link_button("preview.png",  url, :title => "Preview the #{component.class.display_name}: '#{name}'.", :popup => true)
    #else
      #url = polymorphic_url(component, :format => :jnlp)
      #link_button("preview.png",  url,
                  #:title => "Preview the #{component.class.display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.",
                  #:onclick => "show_mac_alert($('launch_warning'),false);")
    #end
  end

  def preview_link_for(component, as_name = nil, params = {})
    x_link_for(component, "preview", as_name, params)
    #component_display_name = component.class.display_name.downcase
    #name = component.name
    #params.update(current_user.extra_params)
    #link_text = params.delete(:link_text) || "preview "
    #if as_name
      #link_text << " as #{as_name}"
    #end

    #url = polymorphic_url(component, :format => :jnlp, :params => params)
    #preview_button_for(component) +
      #link_to(link_text, url,
              #:onclick => "show_mac_alert($('launch_warning'),false);",
              #:title => "Preview the #{component_display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.")
  end

  def run_link_for(component, as_name = nil, params = {})
    x_link_for(component, "run", as_name, params)
    #component_display_name = component.class.display_name.downcase
    #name = component.name
    #params.update(current_user.extra_params)
    #link_text = params.delete(:link_text) || "run "
    #if as_name
      #link_text << " as #{as_name}"
    #end
    #if NOT_USING_JNLPS
      #url = polymorphic_url(component, :format => APP_CONFIG[:runnable_mime_type], :params => params)
    #else
      #url = polymorphic_url(component, :format => :jnlp, :params => params)
    #end
    #if NOT_USING_JNLPS
      #run_button_for(component) + link_to(link_text, url, :popup => true)
    #else
      #run_button_for(component) +
        #link_to(link_text, url,
                #:onclick => "show_mac_alert($('launch_warning'),false);",
                #:title => "run the #{component_display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.")
    #end
  end
end

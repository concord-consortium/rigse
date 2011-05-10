module TemplateHelper

  #- dom_class = element.is_enabled? ? "template_container" : "template_container disabled_section"
  #%div{:id => dom_id_for(element, :template_container), :class => dom_class }
  def template_container_for(container, opts={})
    css_class = [opts[:css_class] || 'template_container']
    prefix = opts[:prefix] || 'template_container'
    unless container.is_enabled
      css_class << 'disabled_section'
    end
    classes = css_class.join " "
    id = dom_id_for(container,prefix)
    capture_haml do
      haml_tag :div, :id=>id, :class => classes do
        haml_tag(:div, :style => "float: right;") do
          haml_tag(:div, "saving", :class => "template_wait")
          haml_tag(:a, "edit", :class => "template_edit_link", :href => "javascript:void(0)") unless opts[:no_edit]
        end
        if block_given? 
          yield
        end
      end
    end
  end

end

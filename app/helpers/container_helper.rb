module TemplateHelper

  #- dom_class = element.is_enabled? ? "template_container" : "template_container disabled_section"
  #%div{:id => dom_id_for(element, :template_container), :class => dom_class }
  def template_container_for(container, opts={})
    css_class = [opts[:css_class] || nil]
    prefix = opts[:prefix]
    css_class << 'disabled_section' unless container.is_enabled
    classes = css_class.join " "
    id = dom_id_for(component,prefix)
    haml_concat "%div{:id=>#{id},:class=>#{classes}}"
  end

end

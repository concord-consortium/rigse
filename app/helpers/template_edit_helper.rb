module TemplateEditHelper 

  #
  # - remote_form_for(section, 
  #   :update => dom_id_for(section, :item), 
  #   :before =>  "tinyMCE.triggerSave(true,true)", 
  #   :success => "alert('success')", 
  #   :loading => "console.log('loading')") do |f|
  # - template_save(section, :update => dom_id_for(section, :item), :before =>  "tinyMCE.triggerSave(true,true)", :success => "alert('success')", :loading => "console.log('loading')") do |f|
  #
  def template_form(component,opts = {}, &block)
    options = {
      :update      => dom_id_for(component, :item),
      :before     => "tinyMCE.triggerSave(true,true)",
      :success    => "template_save_success('#{dom_id_for(component, :item)}')",
      :failure    => "template_save_failure('#{dom_id_for(component, :item)}')",
      :loading    => "template_save_loading('#{dom_id_for(component, :item)}')"
    }
    options.merge!(opts)
    remote_form_for(component,options,&block)
  end

end


module PagesHelper
  
  # def form_for_step(element)
  #   type = element.step_type
  #   # form_html = act.step.form_htm
  #   case type
  #   when 'Xhtml'
  #     element.step.name
  #   when 'MultipleChoice'
  #     element.step.prompt
  #   when 'OpenResponse'
  #     element.step.prompt
  #   end
  # end
  
  def html_for_element(element, mode="edit")
    partial = "pages/#{mode}_#{element.embeddable_type.downcase}"
    html = "could not render partial (#{partial})"
    begin
      html = render(:partial => partial, :object => element)
    rescue => e
      html = "#{html} : #{e}"
    end
    return html
  end

  def link_to_delete (element) 
    render(:partial => 'pages/delete', :object => element)
  end
  
  def link_to_save (element) 
    render(:partial => 'pages/save', :object => element)
  end
  
end

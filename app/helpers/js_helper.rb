module JsHelper

  def js_string_value(object)
    case object
      when Fixnum; return object
      when TrueClass; return object
      when FalseClass; return object
    end
    return "'#{object}'" # use single quotes
  end


  def safe_js(page,dom_id)
    page << "if ($('#{dom_id}')) {"
    yield
    page << "}" 
  end
  
  def dropdown_link_for(link_text="add content",menu_id='add_content',dropdown_id='dropdown')
    return link_to link_text, "#", :onmouseover => "dropdown_for('#{menu_id}','#{dropdown_id}')", :id=>"#{menu_id}"
  end
  
  
end

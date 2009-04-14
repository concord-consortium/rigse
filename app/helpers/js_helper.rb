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
  
end

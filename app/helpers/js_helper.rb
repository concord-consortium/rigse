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
  

  def remove_link(form)
    out = ''
    out << form.hidden_field(:_destroy)
    out << link_to_function("delete", "$('#{dom_id_for(form)}').hide(); $(this).previous().value = '1'", :class=>'delete')
    out
  end

  def add_to_list(pattern)
    # here is a useful prototype pattern: $$('input[name^=multiple_choice\[choices_attributes\]][type=text]')
    # use js console in firefox to test that out.
    # would be great to copy the last
  end
end

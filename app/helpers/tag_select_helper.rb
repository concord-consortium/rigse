module TagSelectHelper

  def tag_selector(tagged_object,object_name,tag_symbol,opts={})
    label = opts[:label] || tag_symbol.to_s.humanize
    clazz = tagged_object.class

    result_string =<<-DONE
    <div class="field_set">
      <label>#{label}</label>
      <br/>
    DONE

    clazz.available_tags("#{tag_symbol.to_s}s".to_sym).each do |tag|
      set = tagged_object.send "#{tag_symbol}_list".to_sym
      result_string << check_box_tag("#{object_name}[#{tag_symbol.to_s}_list][]", tag,set.include?(tag), :id => "#{tag}_tag")
      # result_string << check_box_tag("#{object_name}[#{tag_symbol.to_s}_list][]", tag,set.include? tag)
      result_string << "#{tag}<br/>\n"
    end

    result_string << "</div>"
    result_string
  end

end

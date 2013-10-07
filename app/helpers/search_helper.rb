module SearchHelper

  def order_check_box(order_option, name, current_order)
    is_current = current_order == order_option
    klass = is_current ? "highlightoption" : ""
    control_id = order_option
    output = capture_haml do
      haml_concat(label_tag("sort_order_#{control_id}", name, :class=> klass, :onclick=>'highlightlabel(this)'))
      haml_concat(radio_button_tag(:sort_order, control_id, is_current, :class=>'sort_radio'))
    end
    output
  end

  def build_onSearch_message
    show_message_onSearch= ""
    if @investigations_count == 1
      show_message_onSearch += "#{@investigations_count}  <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"investigations_bookmark\").offsetTop)'>#{t(:investigation)}</a>"
    elsif @investigations_count > 0
      show_message_onSearch += "#{@investigations_count}  <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"investigations_bookmark\").offsetTop)''>#{t(:investigation).pluralize}</a>"
    end

    if @activities_count > 0 && @investigations_count > 0
      show_message_onSearch += ","
    end
    if @activities_count == 1
      show_message_onSearch += " #{@activities_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"activities_bookmark\").offsetTop)'>activity</a>"
    elsif @activities_count > 0
      show_message_onSearch += " #{@activities_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"activities_bookmark\").offsetTop)'>activities</a>"
    end

    show_message_onSearch +=" matching"
    unless @search_term.blank?
      show_message_onSearch +=" search term \"#{@search_term}\" and"
    end
    show_message_onSearch +=" selected criteria"
  end

  def show_material_icon(material)
    if material.material_type == "Investigation"
      # link_url = browse_investigation_url(material)
      icon_url = material.icon_image || "search/investigation.gif"
    elsif material.material_type == "Activity"
      # link_url = browse_activity_url(material)
      icon_url = material.icon_image || "search/activity.gif"
    end
    output = capture_haml do
      haml_concat( image_tag( icon_url, :size => "100x100" ) )
    end
  end

end

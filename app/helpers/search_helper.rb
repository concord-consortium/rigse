module SearchHelper

  def order_check_box(order_option, name, current_order)
    is_current = current_order == order_option
    klass = is_current ? "highlightoption" : ""
    control_id = case(order_option)
    when Search::Oldest
      'updated_at ASC'
    when Search::Newest
      'updated_at DESC'
    when Search::Alphabetical
      'name ASC'
    when Search::Popularity
      'offerings_count DESC'
    end
    output = capture_haml do
      haml_concat(label_tag("sort_order_#{control_id}", name, :class=> klass, :onclick=>'highlightlabel(this)'))
      haml_concat(radio_button_tag(:sort_order, control_id, is_current, :class=>'sort_radio'))
    end
    output
  end

end

module SearchHelper

  def order_check_box(order_option, name, current_order)
    is_current = current_order == order_option
    klass = is_current ? "highlightoption" : ""
    output = capture_haml do
      haml_concat(label_tag(order_option, name, :class=> klass, :onclick=>'highlightlabel(this)'))
      haml_concat(radio_button_tag(:sort_order, order_option, is_current, :class=>'sort_radio'))
    end
    output
  end

end

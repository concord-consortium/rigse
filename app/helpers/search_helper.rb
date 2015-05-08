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

  def build_onSearch_message(form_model)
    investigations_count = form_model.total_entries['Investigation'] || 0
    activities_count = form_model.total_entries['Activity'] || 0
    interactives_count = form_model.total_entries['Interactive'] || 0
    show_message_onSearch= ""
    if investigations_count == 1
      show_message_onSearch += "#{investigations_count}  <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"investigations_bookmark\").offsetTop)'>#{t(:investigation)}</a>"
    elsif investigations_count > 0
      show_message_onSearch += "#{investigations_count}  <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"investigations_bookmark\").offsetTop)''>#{t(:investigation).pluralize}</a>"
    end

    if activities_count > 0 && investigations_count > 0
      show_message_onSearch += ","
    end
    if activities_count == 1
      show_message_onSearch += " #{activities_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"activities_bookmark\").offsetTop)'>activity</a>"
    elsif activities_count > 0
      show_message_onSearch += " #{activities_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"activities_bookmark\").offsetTop)'>activities</a>"
    end

    if interactives_count > 0 && activities_count > 0 && investigations_count > 0
      show_message_onSearch += ","
    end
    if interactives_count == 1
      show_message_onSearch += " #{interactives_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"interactives_bookmark\").offsetTop)'>interactive</a>"
    elsif interactives_count > 0
      show_message_onSearch += " #{interactives_count} <a href='javascript:void(0)' onclick='window.scrollTo(0,$(\"interactives_bookmark\").offsetTop)'>interactives</a>"
    end

    show_message_onSearch +=" matching"
    if (form_model && form_model.text)
      show_message_onSearch +=" search term \"#{form_model.text}\" and"
    end
    show_message_onSearch +=" selected criteria"
  end

  def show_material_icon(material, link_url, hide_details)
    icon_url = material.icon_image
    output = capture_haml do
      haml_tag :div, :class => "material_icon" do
			  unless icon_url.blank?
					unless link_url.nil?
          	haml_tag :a, :href => link_url, :class => "thumb_link" do
            	unless icon_url.blank?
              	haml_tag :img, :src => icon_url, :width=>"100%"
            	end
          	end
				  else
            haml_tag :img, :src => icon_url, :width=>"100%"
          end
        end
      end
    end
    return output
  end

  def assign_material_link(material, action, extra={})
    if current_user && current_user.portal_teacher
      link_to("Assign to a Class", action, extra.merge({:class=>"button"}))
    end
  end

  def assign_material_collection_link(material, action, extra={})
    if current_user && current_user.has_role?("admin")
      link_to("Add to Collection", action, extra.merge({:class=>"button"}))
    end
  end

# convert hash to array
  def authored_grade_level_groupes
    authored_grade_level_groups = []
    @form_model.available_grade_level_groups.each do |grade_level_group_key,grade_level_group_value|
      if grade_level_group_value == 1
        authored_grade_level_groups << grade_level_group_key
      end
    end
    return authored_grade_level_groups
  end
end

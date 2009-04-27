module DataTableHelper
  
  #
  #
  #
  def pack_field_params
    <<-EOF_JS
    $$('.js_target').each(function (t) {
      if (t.value =='') {
        t.remove();
      }
    })
    $('column_names').value = $$('.js_target').pluck('value').join(',');
    $('column_count').value = $$('.js_target').size()
    EOF_JS
  end
  
  #
  # 
  #
  def link_add_column(link_text, dom_id="heading_list") 
    link_to_function link_text,"$('#{dom_id}').insert('#{escape_javascript data_table_heading_tag()}','top')"
  end
  
  #
  # Probably would be good to extract this to a haml partial
  #
  def data_table_heading_tag(heading = "new column")
    <<-EOF_HTML
      <input type="text" size="16" name="heading" class="js_target" value="#{heading}"/>
    EOF_HTML
  end
  
end

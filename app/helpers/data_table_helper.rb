module DataTableHelper
  
  #
  #
  #
  def pack_field_params
    <<-EOF_JS
    $$('.data_table_js_field_target').each(function (t) {
      if (t.value =='') {
        t.remove();
      }
    })
    $('column_names').value = $$('.data_table_js_field_target').pluck('value').join(',');
    $('column_count').value = $$('.data_table_js_field_target').size();
    EOF_JS
  end
  
  #
  # TODO: Confine to one form dom element.
  #
  def pack_cells(form_id,data_dom_id)
    <<-EOF_JS
    $('#{data_dom_id}').value = $$('.data_table_cell').pluck('value').join(',');
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
    <div class="deletable_field_container">
      <input type="text" size="16" name="heading" class="data_table_js_field_target" value="#{heading}"></input>
      #{function_link_button('delete.png',"$(this).up().remove();")}
    </div>
    EOF_HTML
  end
  
  #
  # Probably would be good to extract this to a haml partial
  #
  def data_table_cell_tag(cell_value = "cell",ix=0,iy=0)
    <<-EOF_HTML
    <div class="data_table_cell_conainer">
      <input type="text" size="16" name="cell_#{ix}_#{iy}" class="data_table_cell" value="#{cell_value}"></input>
    </div>
    EOF_HTML
  end  


  def watch_data_fields(data_table, form_id, data_id)
    observe_form(form_id, 
      :before => pack_cells(form_id,data_id),
      :url => { :controller=>:data_tables, :action => :update_cell_data, :id=>data_table.id}, 
      :with => "'data=' + $('#{data_id}').value")
  end
end

  


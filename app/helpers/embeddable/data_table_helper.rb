module Embeddable::DataTableHelper
  
  #
  # Only render a data table title in the body of the table
  # if the author has changed the title from the original default 
  # name: 'Embeddable::DataTable.element', or changed the title from the new
  # default which is an empty string: ''
  #
  def data_table_title(data_table)
    unless data_table.name.empty? || (data_table.name == 'Embeddable::DataTable.element')
      capture_haml do
        haml_tag :div, :class => :data_table_title do
          haml_concat(h(data_table.name))
        end
      end
    end
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
    result = <<-EOF_HTML
    <div class="deletable_field_container">
      <input type="text" size="16" name="heading" class="data_table_js_field_target" value="#{heading}" />
      #{function_link_button('delete.png',"$(this).up().remove();")}
    </div>
    EOF_HTML
    result.html_safe
  end
  
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
  def pack_cells(data_table)
    <<-EOF_JS
    $('#{data_id(data_table)}').value = $$('.#{data_cell_class(data_table)}').pluck('value').join(',');
    EOF_JS
  end
  
  
  
  #
  # Probably would be good to extract this to a haml partial
  #
  # def data_table_cell_tag(cell_value = "cell",ix=0,iy=0)
  #   <<-EOF_HTML
  #   <div class="data_table_cell_conainer">
  #     <input type="text" size="16" name="cell_#{ix}_#{iy}" class="data_table_cell" value="#{cell_value}"></input>
  #   </div>
  #   EOF_HTML
  # end  


  def form_id(data_table)
    dom_id_for(data_table, :data_cell_form)
  end

  def data_id(data_table)
    dom_id_for(data_table, :data)  
  end
  
  def data_cell_class(data_table)
     dom_id_for(data_table, :data_table_cell)
  end

  def watch_data_fields(data_table)
    observe_form(form_id(data_table), 
      :before => pack_cells(data_table),
      :url => { :controller => "embeddable/data_tables", :action => :update_cell_data, :id => data_table.id}, 
      :with => "'data=' + $('#{data_id(data_table)}').value")
  end
end

  


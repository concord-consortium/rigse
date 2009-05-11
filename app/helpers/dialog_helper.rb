module DialogHelper
  
  # Pass in activity_id, or anything else you wanted in options
  def modal_dialog_for(js_page, component, options={})
    defaults = {
      :name       => "new #{component.class.name.humanize}",
      :theme      => 'rites',
      :width      => 800,
      :height     => 400,
      :modal      => true,
      :resizable  => true,
      :draggable  => true,
      :shadow     => true,
      :id         => 'modal_dialog',
      :partial    => "#{component.class.name.pluralize.underscore}/remote_form",
      component.class.name.underscore.to_sym => component
    }
    options = defaults.merge(options)
    options_string = (options.map { |k,v| "#{k.to_s}: #{js_string_value(v)}" }).join(", ")
    js_page << "document.dialog = new UI.Window({#{options_string}});"
    js_page << <<-JAVASCRIPT
      document.dialog.center().setHeader('#{options[:name]}');
      document.dialog.setContent("<div id='_dynamic_content_'>empty</div>");
      document.dialog.show(true);
      document.dialog.focus(true);
      JAVASCRIPT
    js_page['_dynamic_content_'].update(render :layout => false, :partial => options[:partial], :locals => options);
  end


end

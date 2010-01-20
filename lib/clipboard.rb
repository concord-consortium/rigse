module Clipboard
  
  def get_clipboard_object(clipboard_data_type, clipboard_data_id)
    if clipboard_data_type && clipboard_data_type != 'null' && clipboard_data_id
      clipboard_data_type.gsub!('__', '/')
      clazz = clipboard_data_type.classify.constantize
      obj_array = clazz.find(:all, :conditions => {:id => clipboard_data_id})
      obj_array.empty? ? nil : obj_array.first
    else
      nil
    end
  end
  
  def clipboard_object(check_here_first={})
    clipboard_data_type  = check_here_first[:clipboard_data_type] || cookies[:clipboard_data_type]
    clipboard_data_id    = check_here_first[:clipboard_data_id]   || cookies[:clipboard_data_id]
    get_clipboard_object(clipboard_data_type, clipboard_data_id)
  end

  def clipboard_object_name(options={})
    obj = clipboard_object(options)
    name = "(unknown object)"
    if obj
      if (obj.class.respond_to? :display_name) && obj.class.display_name
        name = obj.class.display_name
      else
        name = obj.class.name.humanize
      end
      if (obj.respond_to? :name) && obj.name
        name += ": " + obj.name
      end
    end
    return name
  end
  
end
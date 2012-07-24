def clipboard_scope_char
  '__'
end
def class_scope_char
  '/'
end

class String

  def clipboardify
    self.gsub(class_scope_char, clipboard_scope_char)
  end

  def de_clipboardify
    self.gsub(clipboard_scope_char, class_scope_char)
  end

  def clipboardify!
    self.gsub!(class_scope_char, clipboard_scope_char)
  end
  
  def de_clipboardify!
    self.gsub!(clipboard_scope_char, class_scope_char)
  end
end

module Clipboard
  
  def get_clipboard_object(clipboard_data_type, clipboard_data_id)
    results = nil
    if clipboard_data_type && clipboard_data_type != 'null' && clipboard_data_id
      begin
        clazz = clipboard_data_type.de_clipboardify.classify.constantize
        obj_array = clazz.find(:all, :conditions => {:id => clipboard_data_id})
        results = obj_array.empty? ? nil : obj_array.first
      rescue NameError
        error_message = "unkown object in clipboard %s (id:%d)" % [clipboard_data_type,clipboard_data_id]
        logger.warn(error_message)
        flash[:warn]=error_message
      end
    end
    return results
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
  
  
  def paste_link_for(acceptable_types,options={})
    clipboard_data_type  = options[:clipboard_data_type] || cookies[:clipboard_data_type]
    clipboard_data_id    = options[:clipboard_data_id]   || cookies[:clipboard_data_id]
    container_id         = options[:container_id] || params[:container_id]
    
    return "<span class='copy_paste_disabled'>paste (nothing in clipboard)</span>".html_safe unless clipboard_data_type
    name = clipboard_object_name
    if acceptable_types.include?(clipboard_data_type) 
      url = url_for(
        :action => 'paste', 
        :method=> 'post', 
        :clipboard_data_type => clipboard_data_type, 
        :clipboard_data_id => clipboard_data_id, 
        :id =>container_id)
      return remote_link_button("paste-out.png", 
        :url => url, 
        :title => "paste #{name}") + link_to_remote("paste #{name}", 
        :url=>url)
    end
    return "<span class='copy_paste_disabled'>can't paste #{clipboard_data_type} #{name} here</span>".html_safe
  end
  
end
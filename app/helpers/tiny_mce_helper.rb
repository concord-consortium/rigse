module TinyMceHelper

  def mce_init_string
    <<HEREDOC
tinyMCE.init({
    theme : 'advanced',
    mode : 'textareas',
    plugins : "paste, safari",
    width : '100%',
    height : '100%',
    editor_deselector : "mceNoEditor",
    auto_resize : true,
    remove_script_host : false,
    relative_urls : false,
    content_css : "/stylesheets/otml.css, /stylesheets/project.css",
    gecko_spellcheck : true,
    theme_advanced_resizing : true,
    theme_advanced_resizing_use_cookie : true,
    theme_advanced_toolbar_location : 'top',
    theme_advanced_buttons1 : '#{mce_buttons(1)}',
    theme_advanced_buttons2 : '#{mce_buttons(2)}',
    theme_advanced_buttons3 : '#{mce_buttons(3)}',
    paste_auto_cleanup_on_paste : true,
    paste_preprocess : function(pl, o) {
        // Content string containing the HTML from the clipboard
        // alert(o.content);
    },
    paste_postprocess : function(pl, o) {
        // Content DOM node containing the DOM structure of the clipboard
        // alert(o.node.innerHTML);
    },
    theme_advanced_statusbar_location : 'bottom',
    convert_newlines_to_brs : false,
    convert_fonts_to_spans : true,
    theme_advanced_path : false
});
HEREDOC
  end

  def default_mce_buttons(n)
    case(n)
    when 1
      "bold,italic,underline,|,sup,sub,|,bullist,numlist,|,link,image,|,pastetext,pasteword,selectall,|,justifyleft,justifycenter,justifyright"
    else 
      ""
    end
  end

  def mce_theme_buttons(n)
    mce_config = APP_CONFIG[:tiny_mce]
    if mce_config
      key = "buttons#{n}"
      buttons = mce_config[key.to_sym]
      if buttons.respond_to? :join
        return buttons.join ",|,"
      end
      return buttons
    end
    return nil
  end

  def mce_buttons(n)
    return mce_theme_buttons(n) || default_mce_buttons(n)
  end

end

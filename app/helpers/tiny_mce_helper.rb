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
    content_css : "#{stylesheet_path('otml.css')}, #{stylesheet_path('project.css')}",
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
    theme_advanced_path : false,
    valid_elements: #{valid_elements}
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

  # This is the defaults (according to http://www.tinymce.com/wiki.php/Configuration:valid_elements)
  # along with allowing iframes.
  def valid_elements
    str = "'@[id|class|style|title|dir<ltr?rtl|lang|xml::lang|onclick|ondblclick|"
    str << "onmousedown|onmouseup|onmouseover|onmousemove|onmouseout|onkeypress|"
    str << "onkeydown|onkeyup],a[rel|rev|charset|hreflang|tabindex|accesskey|type|"
    str << "name|href|target|title|class|onfocus|onblur],strong/b,em/i,strike,u,"
    str << "#p,-ol[type|compact],-ul[type|compact],-li,br,img[longdesc|usemap|"
    str << "src|border|alt=|title|hspace|vspace|width|height|align],-sub,-sup,"
    str << "-blockquote,-table[border=0|cellspacing|cellpadding|width|frame|rules|"
    str << "height|align|summary|bgcolor|background|bordercolor],-tr[rowspan|width|"
    str << "height|align|valign|bgcolor|background|bordercolor],tbody,thead,tfoot,"
    str << "#td[colspan|rowspan|width|height|align|valign|bgcolor|background|bordercolor"
    str << "|scope],#th[colspan|rowspan|width|height|align|valign|scope],caption,-div,"
    str << "-span,-code,-pre,address,-h1,-h2,-h3,-h4,-h5,-h6,hr[size|noshade],-font[face"
    str << "|size|color],dd,dl,dt,cite,abbr,acronym,del[datetime|cite],ins[datetime|cite],"
    str << "object[classid|width|height|codebase|*],param[name|value|_value],embed[type|width"
    str << "|height|src|*],script[src|type],map[name],area[shape|coords|href|alt|target],bdo,"
    str << "button,col[align|char|charoff|span|valign|width],colgroup[align|char|charoff|span|"
    str << "valign|width],dfn,fieldset,form[action|accept|accept-charset|enctype|method],"
    str << "input[accept|alt|checked|disabled|maxlength|name|readonly|size|src|type|value],"
    str << "kbd,label[for],legend,noscript,optgroup[label|disabled],option[disabled|label|selected|value],"
    str << "q[cite],samp,select[disabled|multiple|name|size],small,"
    str << "textarea[cols|rows|disabled|name|readonly],tt,var,big,"
    str << "iframe[align<bottom?left?middle?right?top|class|frameborder|height|id"
    str << "|longdesc|marginheight|marginwidth|name|scrolling<auto?no?yes|src|width]'"
    str
  end

end

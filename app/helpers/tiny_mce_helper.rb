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
    content_css : "/stylesheets/app.css",
    gecko_spellcheck : true,
    theme_advanced_resizing : true,
    theme_advanced_resizing_use_cookie : true,
    theme_advanced_toolbar_location : 'top',
    theme_advanced_buttons1     : 'justifyleft,justifycenter,justifyfull,|,bold,italic,underline,|,fontselect,fontsizeselect,',
    theme_advanced_buttons1_add : 'sup,sub,|,bullist,numlist,|,link,image,|,pastetext,pasteword,selectall',
    theme_advanced_buttons2 : '',
    theme_advanced_buttons3 : '',
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

end

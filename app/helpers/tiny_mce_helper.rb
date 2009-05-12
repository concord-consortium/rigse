module TinyMceHelper

  def mce_init_string
    <<HEREDOC
tinyMCE.init({
    theme : 'advanced',
    mode : 'textareas',
    width : '100%',
    height : '100%',
    theme_advanced_resizing : false,
    theme_advanced_toolbar_location : 'top',
    theme_advanced_buttons1     : 'justifyleft,justifycenter,justifyfull,',
    theme_advanced_buttons1_add : '|,bold,italic,underline,|,fontselect,fontsizeselect,|,bullist,numlist,|link,image',
    theme_advanced_buttons2 : '',
    theme_advanced_buttons3 : '',
    theme_advanced_statusbar_location : 'bottom',
    convert_newlines_to_brs : false,
    convert_fonts_to_spans : true,
    theme_advanced_path : false
});
HEREDOC
  end

end

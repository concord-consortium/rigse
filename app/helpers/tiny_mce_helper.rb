module TinyMceHelper

  def mce_init_string
    <<HEREDOC
tinyMCE.init({
  mode : "textareas",
  theme : "advanced",
  theme_advanced_layout_manager : "SimpleLayout",
  theme_advanced_buttons1     : "justifyleft,justifycenter,justifyright,justifyfull,|,bold,italic,underline,strikethrough,",
  theme_advanced_buttons1_add : "|,fontselect,fontsizeselect|,bullist,numlist,hr|,undo,redo,link,unlink,image",
  theme_advanced_buttons2 : "",
  theme_advanced_buttons3 : "",
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  theme_advanced_statusbar_location : "bottom",
  theme_advanced_resizing : true
});
HEREDOC
  end

end

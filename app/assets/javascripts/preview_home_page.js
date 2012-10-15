function preview_home_page(home_page_content_id){
    var preview_content = document.getElementById(home_page_content_id).value
    var preview_window = window.open('','preview_window','fullscreen=yes');
    var form_string = '<form id="preview_project_form" action="/home/preview_home_page" method="post" style=" visibility: hidden"><textarea class="tinymce_textarea" cols="40" id="preview_content_container" name="home_page_preview_content" rows="20">'+preview_content+'</textarea></form>';
    preview_window.document.write(form_string);
    preview_window.document.getElementById('preview_project_form').submit();
}
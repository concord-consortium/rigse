function preview_home_page(homePageContentId, homePageContent, isDomId){
    if(isDomId == true){
        var previewContent = document.getElementById(homePageContentId).value
    }
    else{
        var previewContent = homePageContent
    }
    var previewWindow = window.open('','preview_window','fullscreen=yes');
    var formString = '<form id="preview_project_form" action="/home/preview_home_page" method="post" style="display: none"><textarea class="mceNoEditor" cols="40" id="preview_content_container" name="home_page_preview_content" rows="20">'+previewContent+'</textarea></form>';
    previewWindow.document.write(formString);
    previewWindow.document.getElementById('preview_project_form').submit();
}
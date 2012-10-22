function preview_home_page(homePageContentId, homePageContent){
    var previewContent = null;
    
    if(homePageContentId){
        previewContent = document.getElementById(homePageContentId).value;
    }
    else if (homePageContent){
        previewContent = homePageContent;
    }
    
    if (!previewContent)
    {
        return;
    }
    
    var previewWindow = window.open('','preview_window','height = 700 width = 800, resizable = 1, scrollbars = 1');
    if (!previewWindow)
    {
        // Window did not open. Popup blocker?
        return;
    }
    
    var formString = '<form id="preview_project_form" action="/home/preview_home_page" method="post" style="display: none"><textarea class="mceNoEditor" cols="40" id="preview_content_container" name="home_page_preview_content" rows="20" style="opacity:0;">'+previewContent+'</textarea></form>';
    
    var previewWindowDocument = previewWindow.document;
    
    previewWindowDocument.open();
    previewWindowDocument.write(formString);
    previewWindowDocument.close();
    
    previewWindowDocument.getElementById('preview_project_form').submit();
    
    return;
}
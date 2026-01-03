function preview_teacher_guide_page(teacherGuidePageContentId, teacherGuidePageContent){
    var previewContent = null;

    if (teacherGuidePageContentId){
        previewContent = $(teacherGuidePageContentId).value;
    }
    else if (teacherGuidePageContent === "" || teacherGuidePageContent){
        previewContent = decodeURIComponent(teacherGuidePageContent);
    }

    if (previewContent !== "" && !previewContent)
    {
        return;
    }

    var previewWindow = window.open('','preview_window','height = 700 width = 800, resizable = 1, scrollbars = 1');
    if (!previewWindow)
    {
        // Window did not open. Popup blocker?
        return;
    }

    var formString = '<html>' +
                       '<head>' +
                         '<meta http-equiv="Content-type" value="text/html; charset=UTF-8" />' +
                       '</head>' +
                       '<body>' +
                         '<form id="preview_settings_form" action="/home/preview_teacher_guide_page" method="post" style="display: none;" enctype="application/x-www-form-urlencoded" accept-charset="UTF-8">' +
                           '<textarea id="preview_content_container" name="teacher_guide_page_preview_content" style="opacity:0;">' +
                             previewContent +
                           '</textarea>' +
                         '</form>' +
                       '</body>' +
                     '</html>' +
                     '';

    var previewWindowDocument = previewWindow.document;

    previewWindowDocument.open();
    previewWindowDocument.write(formString);
    previewWindowDocument.close();

    previewWindowDocument.getElementById('preview_settings_form').submit();

    return;
}

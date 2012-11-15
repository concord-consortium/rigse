function openPreviewHelpPage(isExternalUrl, urlOrHtmlContainerId, isDomId, project_id){
      var linkPattern = /(^((http|https|ftp):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ig;
      var protocolPattern = /(^(http|https|ftp):\/\/)/ig;
      var customHtml = null;
      var previewWindow = null;
      var formString = null;
      
      var windowUrl = '';
      var previewWindowDocument = null;
      
      
      if (isExternalUrl)
      {
          windowUrl = $(urlOrHtmlContainerId).value;
          if (!(linkPattern.test(windowUrl))){
            var popupContent="<div style='padding:18px'>Please enter a valid external help URL.</div>";
            showpopup(popupContent);
            return;
          }
          
          if(!protocolPattern.test(windowUrl)){
              windowUrl = 'http://' + windowUrl;
          }
          previewWindow = window.open(windowUrl, 'HelpPagePreviewExternalUrl', 'height = 700 width = 800, resizable = yes, scrollbars = yes');
      }
      else {
          
            
          if(isDomId){
            customHtml = $(urlOrHtmlContainerId).value || false;
            
            if (!customHtml)
            {
                var popupContent = "<div style='padding:18px'>Please enter some custom help HTML to preview.</div>";
                showpopup(popupContent);
                return;
            }
            previewWindow = window.open(windowUrl, 'HelpPagePreviewCustomHtml', 'height = 700 width = 800, resizable = yes, scrollbars = yes');
            if(!previewWindow){
                return;
            }
            formString = '<html>' +
                           '<head>' +
                             '<meta http-equiv="Content-type" value="text/html; charset=UTF-8" />' +
                           '</head>' +
                           '<body>' +
                             '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none;" accept-charset="UTF-8">' +
                               '<textarea id="preview_help_page_content" name="preview_help_page_from_edit" style="opacity:0;">' +
                                 customHtml +
                               '</textarea>' +
                             '</form>' +
                           '</body>' +
                         '</html>'
                         '';
            previewWindowDocument = previewWindow.document;
            previewWindowDocument.open();
            previewWindowDocument.write(formString);
            previewWindowDocument.close();
            previewWindowDocument.getElementById('preview_help_page').submit();
          }
          else{
            previewWindow = window.open(windowUrl, 'HelpPagePreviewCustomHtml', 'height = 700 width = 800, resizable = yes, scrollbars = yes');
            if(!previewWindow){
                return;
            }
            formString = '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none"><textarea id="preview_help_page_content" name="preview_help_page_from_summary_page" style="opacity:0;">'+project_id+'</textarea></form>';
            previewWindowDocument = previewWindow.document;
            previewWindowDocument.open();
            previewWindowDocument.write(formString);
            previewWindowDocument.close();
            previewWindowDocument.getElementById('preview_help_page').submit();
          }
          
      }
}
function showpopup(content)
{
    var okayButton='<div style="text-align:center"><a href="javascript: void(0);" class="button" onclick="close_popup()">OK</a></div>';
    list_modal = new UI.Window({ theme:"lightbox", height:150, width:350});
    list_modal.setContent(content + okayButton).show(true).focus().center();
    list_modal.setHeader("Message");
}

function close_popup()
{
    list_modal.destroy();
    list_modal = null;
}

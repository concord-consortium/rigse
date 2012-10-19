function open_preview_help_page(isExternalUrl, urlOrHtmlContainerId, idDomId, previewCustomHtml){
      var httpPattern = /http/g;
      var customHtml;
      var previewWindow;
      var formString;
      if(idDomId){
        if (isExternalUrl){
            var externalUrl = document.getElementById(urlOrHtmlContainerId).value;
            if (!(/\S/.test(externalUrl))){
                popupContent="<div style='padding:18px'>Please enter a valid external URL.</div>";
                showpopup(popupContent);
            }
            else if(!externalUrl.match(httpPattern)){
                externalUrl = 'http://' + externalUrl;
                window.open(externalUrl,'HelpPage', 'height = 700 width = 800');
            }
        }
        else{
            customHtml = document.getElementById(urlOrHtmlContainerId).value;
            previewWindow = window.open('','help_page', 'height = 700 width = 800');
            formString = '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none"><textarea id="preview_help_page_content" name="preview_help_page_content" style="opacity:0;">'+customHtml+'</textarea></form>';
            previewWindow.document.write(formString);
            previewWindow.document.getElementById('preview_help_page').submit();
            
        }
      }
      else{
          customHtml = previewCustomHtml;
          previewWindow = window.open('','help_page', 'height = 700 width = 800');
          formString = '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none"><textarea id="preview_help_page_content" name="preview_help_page_content" style="opacity:0;">'+customHtml+'</textarea></form>';
          previewWindow.document.write(formString);
          previewWindow.document.getElementById('preview_help_page').submit();
      }
}
function showpopup(content)
{
    var okayButton='<div style="text-align:center"><a href="javascript: void(0);" class="button" onclick="close_popup()">Ok</a></div>';
    list_modal = new UI.Window({ theme:"lightbox", height:150, width:350});
    list_modal.setContent(content + okayButton).show(true).focus().center();
    list_modal.setHeader("Error");
}

function close_popup()
{
    list_modal.destroy();
    list_modal = null;
}

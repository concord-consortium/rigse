function open_preview_help_page(isExternalUrl, urlOrHtmlContainerId, idDomId, previewCustomHtml){
      var httpPattern = /http/g
      if(idDomId){
        if (isExternalUrl){
            var externalUrl = document.getElementById(urlOrHtmlContainerId).value
            if(!externalUrl.match(httpPattern)){
                externalUrl = 'http://' + externalUrl;
            }
            window.open(externalUrl,'HelpPage','fullscreen=yes')
        }
        else{
            var customHtml = document.getElementById(urlOrHtmlContainerId).value
            var previewWindow = window.open('','help_page','fullscreen=yes')
            var formString = '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none"><textarea id="preview_help_page_content" name="preview_help_page_content">'+customHtml+'</textarea></form>'
            previewWindow.document.write(formString);
            previewWindow.document.getElementById('preview_help_page').submit();
            
        }
      }
      else{
          var customHtml = previewCustomHtml
          var previewWindow = window.open('','help_page','fullscreen=yes')
          var formString = '<form id="preview_help_page" name="preview_help_page" action="/help/preview_help_page" method="post" style="display: none"><textarea id="preview_help_page_content" name="preview_help_page_content">'+customHtml+'</textarea></form>'
          previewWindow.document.write(formString);
          previewWindow.document.getElementById('preview_help_page').submit();
      }
}

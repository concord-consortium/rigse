function validate_project_form_help_page_settings(oForm){
    var helpPageOptions = $(oForm).select('input[name=admin_project[help_type]]');
    var selectedOption = 'none selected';
    var popupContent;
    var linkPattern = /(^((http|https|ftp):\/\/){0,1}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ig;
    var protocolPattern = /(^(http|https|ftp):\/\/)/ig;
    
    var externalUrl = $(oForm).select('input[name=admin_project[external_url]]')[0].value;
    if (!(linkPattern.test(externalUrl))){
        popupContent="<div style='padding:18px'>Please enter a valid external URL.</div>";
        showpopup(popupContent);
       return false;
    }
    if(!protocolPattern.test(externalUrl)){
      $(oForm).select('input[name=admin_project[external_url]]')[0].value = 'http://' + externalUrl;
    }
        
    
    
    var customHelpPageHtml = $(oForm).select('textarea[name=admin_project[custom_help_page_html]]')[0].value;
    if (!(/\S/.test(customHelpPageHtml))){
       popupContent="<div style='padding:18px'>Custom HTML cannot be blank if selected for help page.</div>";
       showpopup(popupContent);
       return false;
     }
    
    return true;
}

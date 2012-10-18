function validate_project_form_help_page_settings(oForm){
    debugger;
    alert('1111111111111111111111111111111111111111');
    
    var helpPageOptions = oForm.getElementByName('admin_project[help_type]');
    var selectedOption = 'none selected';
    for (var i = 0; i < helpPageOptions.length; i++){
        if(helpPageOptions[i].checked){
            selectedOption = helpPageOptions[i];
            break;
        }
    }
    if(selectedOption == 'none selected'){
        list_modal = new UI.Window({ theme:"lightbox", width:500});
        list_modal.setContent("<div style='padding:10px'>Select atleast one option for help page</div>").show(true).focus().center();
        list_modal.setHeader("Error");
        return false;
    }
    else if(selectedOption.value = 'external url'){
        var externalUrl = oForm.getElementByName('admin_project[external_url]')[0].value
        if (!(/\S/.test(externalUrl))){
            list_modal = new UI.Window({ theme:"lightbox", width:500});
            list_modal.setContent("<div style='padding:10px'>External url cannot be blank if selected for help page</div>").show(true).focus().center();
            list_modal.setHeader("Error");
            return false;
        }
        
    }
    else if(selectedOption.value = 'help custom html'){
        var customHelpPageHtml = oForm.getElementByName('admin_project[custom_help_page_html]')[0].value
        if (!(/\S/.test(customHelpPageHtml))){
            list_modal = new UI.Window({ theme:"lightbox", width:500});
            list_modal.setContent("<div style='padding:10px'>Custom HTML cannot be blank if selected for help page</div>").show(true).focus().center();
            list_modal.setHeader("Error");
            return false;
        }
    }
    alert('222222222222222222222222222222222222222222222222222222222');
    return true;
}

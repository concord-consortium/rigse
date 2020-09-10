jQuery(function () {
    jQuery('#material_search_form :input:not(#search_term)').on('change', function () {
        // Ignore elements that do not have name attribute. It means they won't be included
        // in GET params anyway and perhaps have only JS handlers.
        if (!jQuery(this).attr('name')) return;
        submitForm();
    });
});

function setAllSensorsSelected(allChecked) {
    var anythingModified = false;
    $$(".sensor_filter_item").each(function(e) {
        // Convert values to boolean, as checked attribute may be a string like "checked".
        if (!!e.checked !== !!allChecked) {
            e.checked = allChecked;
            anythingModified = true;
        }
    });
    if (anythingModified) {
        submitForm();
    }
}

var ajaxRequest;
var goButttondisabled = false;
var animating = false;
var ajaxRequestCounter = 0;

function highlightlabel(e) {
    $$('.highlightoption')[0].removeClassName('highlightoption');
    e.addClassName('highlightoption');
}

function showHideFilters(linkElement, animationDuration) {

    if (animationDuration == undefined) {
      animationDuration = 0.5;
    }

    if (animating) {
        return false;
    }

    var filtersWrapper = $('filters_wrapper');
    var linkText = '';

    var afterFinishCallback = function(){
        animating = false;
    };

    if (filtersWrapper.hasClassName('visible')) {
        linkText = '+ Show Filters';
    } else {
        linkText = '- Hide Filters';
    }
    filtersWrapperToggle(filtersWrapper, animationDuration, afterFinishCallback);
    linkElement.update(linkText);

    return true;
}

var filtersWrapperToggle = function(targetElement, animationDuration, afterFinishCallback){
    Effect.toggle(targetElement, 'blind', { duration: animationDuration, afterFinish: afterFinishCallback });
    targetElement.toggleClassName('visible');
    animating = true;
}

function submitForm() {
    jQuery('#material_search_form').submit();
}

function fulltrim(inputText){
    return inputText.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,'').replace(/\s+/g,' ');
}

var list_modal = null;

function close_popup()
{
    list_lightbox.handle.destroy();
    list_lightbox = null;
}



function get_Assign_To_Class_Popup(assignPopupConfig)
{
    // console.log("[DEBUG] get_Assign_To_Class_Popup skip_reload", skip_reload);
    lightbox_material_text = assignPopupConfig.lightbox_material_text || "Materials";
    var lightboxConfig = {
        content:"<div style='padding:10px'>Loading...Please Wait.</div>",
        id:"assign-and-share",
        title:""
    };
    var searchPath = assignPopupConfig.anonymous ? 'get_current_material_anonymous' : 'get_current_material_unassigned_clazzes';
    var target_url = "/search/" + searchPath + "?skip_reload=" + (assignPopupConfig.skip_reload || false);
    var options = {
        method: 'post',
        parameters: {'material_type': assignPopupConfig.material_type, 'material_id': assignPopupConfig.material_id},
        onSuccess: function(transport) {
            list_lightbox=new Lightbox(lightboxConfig);
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold'></div>"+ text;
            list_lightbox.handle.setContent("<div id='windowcontent' style='overflow: hidden;'>" + text + "</div>");
            var contentheight=$('windowcontent').getHeight()/2;
            var contentoffset=75;
            list_lightbox.handle.setSize(760,contentheight+contentoffset+20);
            list_lightbox.handle.center();
        }
    };
    new Ajax.Request(target_url, options);
}

var g_saveAssignToClassInProgress = false;

function validateSaveAssignToClass()
{
    var returnValue = false;
    var g_showSelected = false;
    $$(".unassigned_activity_class").each(function(obj){ g_showSelected = g_showSelected || obj.checked;});

    if(!g_showSelected)
    {
        var description_text = "No check boxes have been selected.";
        setSaveAssignToClassInProgress(false);
    }
    if (g_saveAssignToClassInProgress)
    {
        return returnValue;
    }
    returnValue = true;
    return returnValue;
}

function setSaveAssignToClassInProgress(value)
{
    g_saveAssignToClassInProgress = !!value;
    return;
}

document.observe("dom:loaded", function() {
    var objquery=window.location.href.parseQuery([separator = '&']);
    if (objquery.type!==undefined)
    {
        if (objquery.type=='act')
        {
            window.scrollTo(0,$("activities_bookmark").offsetTop);
        }
         if (objquery.type=='inv')
        {
            window.scrollTo(0,$("investigations_bookmark").offsetTop);
        }
    }
});

function checkActivityToAssign(chk_box)
{
    var allCheckboxElements = $$('input[type="checkbox"][name="'+chk_box.name+'"]');
    var checkedElements = [];

    allCheckboxElements.each(function (element) {
        if (element.checked) {
            checkedElements.push(element);
        }
    });

    var btnAssign = $("btn_Assign");
    var materialId = '';
    var assignMaterialType = '';

    if(allCheckboxElements.length == checkedElements.length){
        btnAssign.innerHTML = "Assign Investigation";
        materialId = $("investigation_id").getValue();
        assignMaterialType = "Investigation";
    }
    else if(checkedElements.length > 0) {
        btnAssign.innerHTML = "Assign Individual Activities";
        materialId = checkedElements.pluck("value").join(",");
        assignMaterialType = "Activity";
    }

    $("material_id").setValue(materialId);
    $("assign_material_type").setValue(assignMaterialType);

    return;
}

function getDataForAssignToClassPopup(lightbox_material_text, anonymous)
{
    var material_id = $("material_id").getValue("");
    var material_type = $("assign_material_type").getValue("");
    if(material_id.length <= 0)
    {
        var message = "<div class='feedback_message'>Please select at least one activity to assign to a class.</div>";
        getMessagePopup(message);
        return;
    }
    var assignPopupConfig = {
      material_id: material_id,
      material_type: material_type,
      lightbox_material_text: lightbox_material_text,
      skip_reload: true,
      anonymous: anonymous
    }
    PortalComponents.renderAssignToClassModal(assignPopupConfig);
}

var g_messageModal = null;

function getMessagePopup(message, skip_reload)
{
    // console.log("[DEBUG] getMessagePopup skip_reload", skip_reload);

    g_messageModal = g_messageModal || null;
    if(g_messageModal !== null)
    {
        g_messageModal.close();
    }

    var content = "<div style='padding:10px 15px;'>" +
                  message +
                  "</div>";

    var lightboxConfig = {
        width: 375,
        height: 250,
        closeOnNextPopup: true,
        type: Lightbox.type.ALERT,
        content: content,
        callback: function(){
            if (!skip_reload) {
                location.reload();
            }
        }
    };

    g_messageModal = new Lightbox(lightboxConfig);

}

function setPopupHeight()
{
    var contentheight=$('windowcontent').getHeight();
    var contentoffset=40;
    list_lightbox.handle.setSize(500,contentheight+contentoffset);
    list_lightbox.handle.center();
}


function msgPopupDescriptionText(assignPopupConfig) {
  var popupMessage = "Please log-in or <a href='javascript:Portal.openSignupModal();'>register</a> as a teacher to assign this material.";
  getMessagePopup(popupMessage);
}

// Export assignMaterialToClass to Portal namespace.
// `className` is either: 'ExternalActivity', 'Activity' or 'Investigation'.
Portal.assignMaterialToClass = function(id, className, lightbox_material_text) {
  var assignPopupConfig = {
    material_id: id,
    material_type: className,
    lightbox_material_text: lightbox_material_text,
    skip_reload: true,
    anonymous: false
  }
  PortalComponents.renderAssignToClassModal(assignPopupConfig);
};

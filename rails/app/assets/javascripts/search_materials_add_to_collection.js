
function get_Assign_To_Collection_Popup(material_id,
                                        material_type,
                                        lightbox_material_text,
                                        skip_reload )
{
    lightbox_material_text = lightbox_material_text || "Materials";
    var lightboxConfig = {
        content:"<div style='padding:10px'>Loading...Please Wait.</div>",
        title:"Assign " + lightbox_material_text + " to a Collection"
    };
    var target_url = "/search/get_current_material_unassigned_collections?skip_reload=" + (skip_reload || false);
     var options = {
        method: 'post',
        parameters : {'material_type':material_type,'material_id':material_id},
        onSuccess: function(transport) {
            list_lightbox=new Lightbox(lightboxConfig);
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold'></div>"+ text;
            list_lightbox.handle.setContent("<div id='windowcontent' style='padding:10px'>" + text + "</div>");
            var contentheight=$('windowcontent').getHeight();
            var contentoffset=40;
            list_lightbox.handle.setSize(500,contentheight+contentoffset+20);
            list_lightbox.handle.center();
        }
    };
    new Ajax.Request(target_url, options);
}

var g_saveAssignToCollectionInProgress = false;

function validateSaveAssignToCollection()
{
    var returnValue = false;
    var g_showSelected = false;
    $$(".unassigned_activity_collection").each(function(obj){ g_showSelected = g_showSelected || obj.checked;});

    if(!g_showSelected)
    {
        var description_text = "No check boxes have been selected.";
        setSaveAssignToCollectionInProgress(false);
    }
    if (g_saveAssignToCollectionInProgress)
    {
        return returnValue;
    }
    returnValue = true;
    return returnValue;
}

function setSaveAssignToCollectionInProgress(value)
{
    g_saveAssignToCollectionInProgress = !!value;
    return;
}

function getDataForAssignToCollectionPopup(lightbox_material_text)
{
    var material_id = $("material_id").getValue("");
    var material_type = $("assign_material_type").getValue("");
    if(material_id.length <= 0)
    {
        var message = "<div class='feedback_message'>Please select at least one activity to assign to a collection.</div>";
        getMessagePopup(message);
        return;
    }
    get_Assign_To_Collection_Popup(material_id,material_type, lightbox_material_text);
}

// Export assignMaterialToCollection to Portal namespace.
// `className` is either: 'ExternalActivity', 'Activity' or 'Investigation'.
Portal.assignMaterialToCollection = function(id, className, lightbox_material_text) {
    get_Assign_To_Collection_Popup(id, className, lightbox_material_text);
};

Portal.assignMaterialToSpecificClass = function(assign, classId, materialId, materialClassName) {
    params = {
      assign: assign ? 1 : 0,
      class_id: classId,
      material_id: materialId,
      material_type: materialClassName
    };
    jQuery.post(Portal.API_V1.ASSIGN_MATERIAL_TO_CLASS, params);
};

function add_Edit_Class_Teachers()
{
    modal_window = new UI.Window({ theme:"rites", width:300, height:350}).setContent("<div style='padding:10px'>Loading...Please Wait.</div>").show(true).focus().center();
    modal_window.setHeader("Modify Teacher List");
    var clazz_id = $("portal_clazz_id").value;
    var options = {
        method: 'post',
        onSuccess: function(transport) {
            var text = transport.responseText;
            text += "<div><table cellpadding='5' align='right'><tr>"+
            "<td><input type='button' value='Save' id='AddTeacherSaveButton' onclick='save_Class_Teacher_List(this)' class='pie' /></td>"+
            "<td><a class='hlink' onclick='close_popup()'>Cancel</a></td>"+
            "</table></div>";
            modal_window.setContent("<div style='padding:10px'>" + text + "</div>");
        }
    };
    var target_url = "/portal/classes/"+clazz_id+"/get_teachers";
    new Ajax.Request(target_url, options);
}

function close_popup()
{
    modal_window.hide();
}

function save_Class_Teacher_List(btnSave)
{
    btnSave.disabled = true;
    
    var clazz_id = $("portal_clazz_id").value;
    var arrSelectedTeachers = [];
    var arrCkhBoxes = document.getElementsByName("clazz_teacher[]");
    for(var i=0; i< arrCkhBoxes.length; i++)
    {
        if (arrCkhBoxes[i].checked){
            arrSelectedTeachers.push(arrCkhBoxes[i].value);
        }
    }
    var options = {
        method: 'post',
        parameters: "clazz_teacher_ids=" + arrSelectedTeachers,
        onSuccess: function(transport) {
            var text = transport.responseText;
            close_popup();
        }
    };
    var target_url = "/portal/classes/"+clazz_id+"/edit_teachers";
    new Ajax.Request(target_url, options);
}

var strDraggedElementCheckBoxID="";
var bDraggedElementChecked;

function ChangeOrder(elementDragged)
{
    var oDraggedElementCheckBox = $$('#'+elementDragged.element.id+' input:[type="checkbox"]')[0];
    strDraggedElementCheckBoxID = oDraggedElementCheckBox.id;
    bDraggedElementChecked = oDraggedElementCheckBox.checked;
}

function UpdateOrder()
{
    var oDraggedElementCheckBox;
    if(strDraggedElementCheckBoxID.length > 0)
    {
        setTimeout (function(){
            document.getElementById(strDraggedElementCheckBoxID).checked = bDraggedElementChecked;
            strDraggedElementCheckBoxID = "";
            },20);
    }
}

document.observe("dom:loaded", function() {
    if (!("sortable" in Sortable.sortables))
    {
        return;
    }
    
    Sortable.sortables.sortable.draggables.each(function(oDraggable){
        oDraggable.options.change = ChangeOrder;
        oDraggable.options.onEnd = UpdateOrder;
    });
});


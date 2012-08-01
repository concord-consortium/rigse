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


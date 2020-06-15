var expandedShareButtonid="";
function expandcollapseoptions(id,material_type,btn_type){
    if((material_type+id+btn_type)!=expandedShareButtonid)
    {
        $$(".Expand_Collapse").each(function(shareContainer){shareContainer.hide();shareContainer.removeClassName('visible');});
        $$(".Expand_Collapse_Link").each(function(sharebtn){
            if (sharebtn.hasClassName('preview_Button'))
                {
                    sharebtn.update("Preview &#9660");
                }
            else
                sharebtn.update("Share &#9660");
                });
    }
    var shareContainer=$(material_type+id+btn_type);
    if (shareContainer.hasClassName('visible'))
    {
        shareContainer.hide();
        shareContainer.removeClassName('visible');
        expandCollapseText = btn_type + " &#9660;";
        $('ExpandCollapse_'+material_type+id+btn_type).update(expandCollapseText);
    }
    else
    {
        shareContainer.show();
        shareContainer.addClassName('visible');
        expandCollapseText = btn_type + " &#9650;";
        expandedShareButtonid=material_type+id+btn_type;
        $('ExpandCollapse_'+material_type+id+btn_type).update(expandCollapseText);
    }
    return true;
}

function hideSharelinks(){
    
    $$(".Expand_Collapse").each(function(shareContainer){
            if (shareContainer.hasClassName('visible'))
            {
                shareContainer.hide();
                shareContainer.removeClassName('visible');
            }
        });
    $$(".Expand_Collapse_Link").each(function(sharebtn){
            if (sharebtn.hasClassName('preview_Button'))
                {
                    sharebtn.update("Preview &#9660");
                }
            else
                sharebtn.update("Share &#9660");
            });
}

document.observe("click",function(obj){
    var oElem= obj.srcElement || obj.target;
    if (expandedShareButtonid!=="")
    {
        if ($(expandedShareButtonid).hasClassName("visible"))
        {
             if(oElem.descendantOf(expandedShareButtonid) && $(expandedShareButtonid).hasClassName("Expand_Collapse_share"))
            {
                return false;
            }
        }
    }
    if(oElem.hasClassName("Expand_Collapse_Link")===false)
    {
        hideSharelinks();
        expandedShareButtonid="";
    }
});

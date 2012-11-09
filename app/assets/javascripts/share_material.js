var expandedShareButtonid;
function expandcollapseoptions(id,material_type,btn_type){
    if (animating)
    {
        return false;
    }
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
    var afterFinishCallback = function(){
        animating = false;
        $('ExpandCollapse_'+material_type+id+btn_type).update(expandCollapseText);
    };
    
    if (shareContainer.hasClassName('visible'))
    {
        Effect.BlindUp(shareContainer, { duration: 0.2, afterFinish: afterFinishCallback });
        shareContainer.removeClassName('visible');
        expandCollapseText = btn_type + " &#9660;";
        animating = true;
    }
    else
    {
        Effect.BlindDown(shareContainer, { duration: 0.2, afterFinish: afterFinishCallback });
        shareContainer.addClassName('visible');
        expandCollapseText = btn_type + " &#9650;";
        expandedShareButtonid=material_type+id+btn_type;
        animating = true;
    }
    return true;
}

function hideSharelinks(){
    
    $$(".Expand_Collapse").each(function(shareContainer){
            if (animating)
             {   
                return false;
             }
            if (shareContainer.hasClassName('visible'))
            {
                Effect.BlindUp(shareContainer, { duration: 0.2});
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
    if(obj.srcElement.hasClassName("Expand_Collapse_Link")===false)
    {
        hideSharelinks();
    }
});

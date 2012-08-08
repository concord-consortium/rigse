function showInstructionalMaterial(oMaterialTab){
    setTableHeaders(1);
    var oSelectedTab = $$('.selected_tab')[0];
    if(oSelectedTab){
        oSelectedTab.removeClassName('selected_tab');
        oSelectedTab.addClassName('tab');
        $(oSelectedTab.id + "_data").hide();
    }
    
    oMaterialTab.removeClassName('tab');
    oMaterialTab.addClassName('selected_tab');
    $(oMaterialTab.id + "_data").show();
    
    setTableHeaders();
}

function startScroll(direction,size){
    oTimer = setInterval(function(){ 
        var scroller = document.getElementById('oTabcontainer');
        if (direction == 'l') {
            scroller.scrollLeft -= size;
        }
        else if (direction == 'r') {
            scroller.scrollLeft += size;
        }
    },20);
}

function stopScroll(){
    clearTimeout(oTimer);
}

function showHideActivityButtons(investigation_id, oLink){
    var bVisible = false;
    $$('.activitybuttoncontainer_'+investigation_id).each(function(oButtonContainer){
        oButtonContainer.toggle();
        bVisible = bVisible || oButtonContainer.getStyle('display')=='none';
    });
    
    var strLinkText = "";
    var strExpandCollapseText = "";
    if(bVisible){
        strLinkText = "Show Activities";
        strExpandCollapseText = "+";
    }
    else{
        strLinkText = "Hide Activities";
        strExpandCollapseText = "-";
    }
    
    $('oExpandCollapseText_'+investigation_id).update(strExpandCollapseText);
    oLink.update(strLinkText);
}


function showHideActivityDetails(investigation_id, oLink){
    setTableHeaders(1);
    var bVisible = false;
    $$('.DivHideShowDetail'+investigation_id).each(function(oButtonContainer){
        oButtonContainer.toggle();
        bVisible = bVisible || oButtonContainer.getStyle('display')=='none';
    });
    
    var strLinkText = "";
    var strExpandCollapseText = "";
    if(bVisible){
        strLinkText = "Show detail";
        strExpandCollapseText = "+";
    }
    else{
        strLinkText = "Hide detail";
        strExpandCollapseText = "-";
    }
    
    $('oExpandCollapseText_'+investigation_id).update(strExpandCollapseText);
    oLink.update(strLinkText);
    setTableHeaders();
}


function setSelectedTab(strTabID){
    $(strTabID).simulate('click');
    $$('.scrollertab').each(function(oTab){
        var strDirection = oTab.hasClassName('tableft')? "l" : "r";
        oTab.observe('mouseover',function(){
            startScroll(strDirection,5);
        });
        oTab.observe('mouseout',stopScroll);
    });
}

document.observe("dom:loaded", function() {
    var arrTabs = $$('#oTabcontainer .tab');
    arrTabs.each(function(oTab){
        oTab.observe('click',function(){
            showInstructionalMaterial(oTab);
        });
    });
    setTableHeaders(1);
    if (arrTabs.length > 0)
    {
        var strTabID = arrTabs[0].id;
        setSelectedTab(strTabID);
    }

});

function setTableHeaders(iDefaultWidth)
{
    var iWidth;
    var iContainerWidth;
    $$("th.expand_collapse_text").each(function(oTitle){
        var oChild = oTitle.childElements()[0];
        if(oChild)
        {
            iContainerWidth = (oTitle.offsetWidth > 0)? oTitle.offsetWidth-10 : 1;
            if(iDefaultWidth)
                iWidth = iDefaultWidth;
            else
                iWidth = (oTitle.getStyle('display') == "none")? 1 : iContainerWidth;
            oChild.setStyle({'display':'none'});
            oChild.setStyle({'width':iWidth+'px'});
        }
    });
    
    $$("th.expand_collapse_text > div.progressbar_container").each(function(oTitle){
        oTitle.setStyle({'display':''});
    });
}

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


function showHideActivityDetails(investigation_id, oLink, strURL){
    setRecentActivityTableHeaders(1,investigation_id);
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

    if($('DivHideShowDetail'+investigation_id).children.length === 0)
        new Ajax.Request(strURL, {asynchronous:true, evalScripts:true, method:'post'});

    setRecentActivityTableHeaders(null,investigation_id);
}


// handle the material select
document.observe("dom:loaded", function() {
    var materialSelect = $$("select#material_select");
    if (materialSelect.length > 0) {
        var dataContainers = $$('.data_container > div');
        if (dataContainers.length > 0) {
            $(dataContainers[0]).show();
        }
        materialSelect.each(function(oSelect){
            oSelect.observe('change', function() {
                dataContainers.each(Element.hide);
                $($(this).getValue()).show();
            });
        });
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
            iContainerWidth = (oTitle.offsetWidth > 10)? oTitle.offsetWidth-10 : 1;
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

function setRecentActivityTableHeaders(iDefaultWidth,offering_id)
{
    var iWidth;
    var iContainerWidth;
    $$(".DivHideShowDetail"+ offering_id + " th.expand_collapse_text").each(function(oTitle){
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

function openReportLinkPopup(descriptionText)
{
    var popupHtml = "<div id='windowcontent' style='padding:10px;padding-left:15px'>" +
                    descriptionText +
                    "</div>";
    var reportLinkPopup = new Lightbox({
        width:  410,
        height: 125,
        title: "Message",
        content: popupHtml,
        type: Lightbox.type.ALERT
    });

    return;
}


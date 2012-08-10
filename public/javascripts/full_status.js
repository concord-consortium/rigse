function showHideDetailedSummary(investigation_id, bShowDetails, strURL)
{
    setTableHeaders(1);
    var arrSummaryRows = $$(".investigation_summary_row_" + investigation_id);
    var arrDetailRows = $$(".investigation_detail_row_" + investigation_id);
    var strSummaryRowDisplay = "";
    var strDetailRowDisplay = "";
    if(bShowDetails)
    {
        strSummaryRowDisplay = "none";
        strDetailRowDisplay = "";
    }
    else
    {
        strSummaryRowDisplay = "";
        strDetailRowDisplay = "none";
    }
    
    arrSummaryRows.each(function(oSummaryRow){
        oSummaryRow.setStyle({'display':strSummaryRowDisplay});
    })
    arrDetailRows.each(function(oDetailRow){
        oDetailRow.setStyle({'display':strDetailRowDisplay});
    })
    
    setTableHeaders();
    
    new Ajax.Request(strURL, {asynchronous:true, evalScripts:true, method:'post'});
}

document.observe("dom:loaded", function() {
    setTableHeaders()
});


function setTableHeaders(iDefaultWidth)
{
    var iWidth;
    $$("th.expand_collapse_text").each(function(oTitle){
        var oChild = oTitle.childElements()[0]
        if(oChild)
        {
            if(iDefaultWidth)
                iWidth = iDefaultWidth
            else
                iWidth = (oTitle.getStyle('display') == "none")? 1 : oTitle.offsetWidth*0.9
            oChild.setStyle({'display':'none'}) 
            oChild.setStyle({'width':iWidth+'px'})
        }
    })
    
    $$("th.expand_collapse_text > div.progressbar_container").each(function(oTitle){
        oTitle.setStyle({'display':''})
    })
}

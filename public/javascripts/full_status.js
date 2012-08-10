function showHideDetailedSummary(investigation_id, bShowDetails, strURL)
{
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
    
    new Ajax.Request(strURL, {asynchronous:true, evalScripts:true, method:'post'});
}

var suggestioncount = -1;
var ajaxRequest;
var ajaxRequestSend = 0;
var goButttondisabled=false;
var animating=false;
var ajaxRequestCounter = 0;
function select_suggestion(search_box) {
    var strSuggestiontext;
    try{
        strSuggestiontext = fulltrim(search_box.textContent);
    }
    catch(e){
        strSuggestiontext = fulltrim(search_box.innerText);
    }
    $('search_term').value = strSuggestiontext;
    $('suggestions').remove();
    //$('show_suggestion').writeAttribute('name','no_suggestion');
    suggestioncount = -1;
}

function highlightlabel(e) {
    $$('.highlightoption')[0].removeClassName('highlightoption');
    e.addClassName('highlightoption');
}

function searchsuggestions(e, oElement) {
    var enter_key_code = 13;
    var downArrow_key_code = 40;
    var upArrow_key_code = 38;
    var escape_key_code = 27;
    
    if(e.keyCode == enter_key_code || e.keyCode == downArrow_key_code || e.keyCode == upArrow_key_code || e.keyCode == escape_key_code) {
        return false;
    }
    ajaxRequestCounter ++;
    ajaxRequest = new Ajax.Request('/search/get_search_suggestions', {
        parameters : {
            search_term : oElement.value,
            ajaxRequestCounter:ajaxRequestCounter
        },
        method : 'get'
    });
    ajaxRequestSend = 1;
}

function showsuggestion(event, oelem) {
    var enter_key_code = 13;
    var downArrow_key_code = 40;
    var upArrow_key_code = 38;
    var escape_key_code = 27;

    if(event.keyCode == escape_key_code){
        //
        $('search_suggestions').hide();
        if(event.stop){
            event.stop();
        }
        else{
            event.returnValue = false;
        }
        
        return;
    }
    var osuggestions = $$('.suggestion');
    var ohoverelements = $$('.suggestionhover');
    $('search_suggestions').show();
    if(osuggestions.length === 0) {
        if(event.keyCode == enter_key_code) {
            submitsuggestion();
        }
        return;
    }
    if(ohoverelements.length > 0) {
        ohoverelements[0].removeClassName('suggestionhover');
    }
    switch (event.keyCode) {
        case downArrow_key_code:
            suggestioncount++;
            if(suggestioncount >= osuggestions.length) {
                suggestioncount = 0;
            }
            osuggestions[suggestioncount].addClassName('suggestionhover');
            break;

        case upArrow_key_code:
            suggestioncount--;
            if(suggestioncount <= -1) {
                suggestioncount = osuggestions.length - 1;
            }
            osuggestions[suggestioncount].addClassName('suggestionhover');
            break;

        case enter_key_code:
            if(suggestioncount != -1) {
                select_suggestion(osuggestions[suggestioncount]);
                suggestioncount = -1;
            }

            submitsuggestion();
            break;

        default:
            suggestioncount = -1;
    }
}

function showHideFilters(linkElement) {
    
    if (animating)
    {
        return false;
    }
    
    var filtersWrapper = $('filters_wrapper');
    var linkText = "";
    var expandCollapseText = "";
    var afterFinishCallback = function(){
        animating = false;
    };
    
    if (filtersWrapper.hasClassName('visible'))
    {
        Effect.BlindUp(filtersWrapper, { duration: 0.5, afterFinish: afterFinishCallback });
        filtersWrapper.removeClassName('visible');
        linkText = "Show Filters";
        expandCollapseText = "+";
        animating = true;
    }
    else
    {
        Effect.BlindDown(filtersWrapper, { duration: 0.5, afterFinish: afterFinishCallback });
        filtersWrapper.addClassName('visible');
        linkText = "Hide Filters";
        expandCollapseText = "-";
        animating = true;
    }
    
    $('oExpandCollapseText').update(expandCollapseText);
    linkElement.update(linkText);
    
    return true;
}

function uncheckedallprobes(allChecked) {
    $$(".probe_items").each(function(e) {
        e.checked = allChecked;
    });
    if(allChecked)
        $('probe_0').checked = !allChecked;
    if($('probe_0').checked){
        $('probe_0').checked = !allChecked;
        $('probes_overlay').style.display='block';
    }
    else
        $('probes_overlay').style.display='none';
}

function removesuggestions() {
    $('suggestions').remove();
}

function preventsubmit() {
    $('prevent_submit').setValue(1);
}

function allowsubmit() {
    $('prevent_submit').setValue(0);
}

function submitsuggestion() {
    $('prevent_submit').setValue(0);
    document.getElementsByName('GO')[0].click();
}

function CheckSubmitStatus() {
    var oVal = $('prevent_submit');
    if(oVal.value == 1) {
        oVal.setValue(0);
        return false;
    } else {
        return true;
    }
}

function disableForm(){
    preventsubmit();
    $('search_term').addClassName('disabledGo');
    $('filter_container').addClassName('disabledfilters');
    document.getElementsByName('GO')[0].addClassName('disabledGo');
    goButttondisabled=true;
}

function enableForm(){
    allowsubmit();
    $('search_term').removeClassName('disabledGo');
    $('filter_container').removeClassName('disabledfilters');
    document.getElementsByName('GO')[0].removeClassName('disabledGo');
    goButttondisabled=false;
}

function abortAjaxRequest() {
    
    if(ajaxRequestSend) {
        ajaxRequest.transport.abort();
        ajaxRequestSend = 0;
        $('search_suggestions').hide();
        if($('suggestions')) {
            $('suggestions').remove();
        }
    }
}

var startUpdate = function(progress_sel,update_sel) {
  if (typeof progress_sel == 'undefined')  { progress_sel = 'search_spinner';      }
  if (typeof update_sel == 'undefined')    { update_sel = 'offering_list';  }
  $(update_sel).hide();
  $(progress_sel).show();
};

var endUpdate = function (progress_sel, update_sel) {
  if (typeof progress_sel == 'undefined')  { progress_sel = 'search_spinner';      }
  if (typeof update_sel == 'undefined')    { update_sel = 'offering_list';  }
  $(update_sel).show();
  $(progress_sel).hide();
};


function LoadingStart (pre,post) {
  disableForm();
  if (typeof pre == 'undefined' )  { pre  = startUpdate; }
  if (typeof post == 'undefined') { post = endUpdate;  }
  PendingRequests++;
  pre.call();
  if (typeof PendingQue[post] == 'undefined') {
    PendingQue[post] = 0;
  }
  else {
    PendingQue[post] = PendingQue[post] + 1;
  }
}

function LoadingEnd (post) {
  enableForm();
  if (typeof post == 'undefined') { post = endUpdate;  }
  PendingRequests--;
  if (typeof PendingQue[post] == 'undefined') { 
    PendingQue[post] = 0;
    //console.log("ERROR: PendingEnd called before PendingStart");
  }
  else {
    PendingQue[post] = PendingQue[post] - 1;
  }
  if (PendingQue[post] < 1) {
    post.call();
  }
}

function fulltrim(inputText){
    return inputText.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,'').replace(/\s+/g,' ');
}

var list_modal = null;

function close_popup()
{
    list_modal.destroy();
    list_modal = null;
}

function get_Assign_To_Class_Popup(material_id,material_type)
{
    list_modal = list_modal || null;
    if(list_modal !== null)
    {
        close_popup();
    }
    list_modal = new UI.Window({ theme:"lightbox", width:500});
    list_modal.setContent("<div style='padding:10px'>Loading...Please Wait.</div>").show(true).focus().center();
    list_modal.setHeader("Assign Materials to a Class");
    
    var options = {
        method: 'post',
        parameters : {'material_type':material_type,'material_id':material_id},
        onSuccess: function(transport) {
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold'></div>"+ text;
            list_modal.setContent("<div id='windowcontent' style='padding:10px'>" + text + "</div>");
            var contentheight=$('windowcontent').getHeight();
            var contentoffset=40;
            list_modal.setSize(500,contentheight+contentoffset);
            list_modal.center();
        }
    };
    var target_url = "/search/get_current_material_unassigned_clazzes";
    new Ajax.Request(target_url, options);
}
function materialCheckOnClick(ObjId)
{
    if(!$('investigation').checked &&  !$('activity').checked ){
        $(ObjId).checked="checked";
    }

}

var g_saveAssignToClassInProgress = false;

function validateSaveAssignToClass()
{
    var returnValue = false;
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

function selectAllGreades(gradeObj,grades)
{
    
    if(gradeObj.id == 'allgrades'){
        if($(gradeObj).checked){
            grades.each(function(obj){
                $(obj).checked= "checked";
            });
        }
        else if(!$(gradeObj).checked){
            grades.each(function(obj){
                $(obj).checked= false;
            });
        }
    }
    else {
        if(!$(gradeObj).checked){
            $('allgrades').checked= false;
        }
        else{
            allgrades_selected = true;
            grades.each(function(obj){
                allgrades_selected = allgrades_selected && $(obj).checked;
                
            });
            if(allgrades_selected){
                $('allgrades').checked= "checked";
            }
        }
    }
}

function uncheckednoprobe(probeObj)
{
    if($(probeObj).checked){
        $('probe_0').checked= false;
    }
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

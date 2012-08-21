var suggestioncount = -1;
var ajaxRequest;
var ajaxRequestSend = 0;
var goButttondisabled=false;
var animating=false;
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
    if(e.keyCode == 13 || e.keyCode == 40 || e.keyCode == 38) {
        // if(e.keyCode == 13)
        return false;
    }
    ajaxRequest = new Ajax.Request('/search/get_search_suggestions', {
        parameters : {
            search_term : oElement.value
        },
        method : 'get'
    });
    ajaxRequestSend = 1;
}

function showsuggestion(event, oelem) {
    // $('show_suggestion').writeAttribute('name','show_suggestion');
    var osuggestions = $$('.suggestion');
    var ohoverelements = $$('.suggestionhover');
    $('search_suggestions').show();
    if(osuggestions.length === 0) {
        if(event.keyCode == 13) {
            submitsuggestion();
        }
        return;
    }
    if(ohoverelements.length > 0) {
        ohoverelements[0].removeClassName('suggestionhover');
    }
    switch (event.keyCode) {
        case 40:
            suggestioncount++;
            if(suggestioncount >= osuggestions.length) {
                suggestioncount = 0;
            }
            osuggestions[suggestioncount].addClassName('suggestionhover');
            break;

        case 38:
            suggestioncount--;
            if(suggestioncount <= -1) {
                suggestioncount = osuggestions.length - 1;
            }
            osuggestions[suggestioncount].addClassName('suggestionhover');
            break;

        case 13:
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

function showHideFilters(oLink) {
    
    var filterwrapper=$('filters_wrapper');
    var strLinkText = "";
    var strExpandCollapseText = "";
    if (animating)
    {
        return false;
    }
    if(filterwrapper.hasClassName('visible'))
    {
     Effect.BlindUp('filters_wrapper', { duration: 0.5 });
     filterwrapper.removeClassName('visible');
     strLinkText = "Show Filters";
     strExpandCollapseText = "+";
     animating=true;
     setTimeout(function(){
         animating=false;
     },500);
    }
    else
    {
     Effect.BlindDown('filters_wrapper', { duration: 0.5 });
     filterwrapper.addClassName('visible');
     strLinkText = "Hide Filters";
     strExpandCollapseText = "-";
     working=true;
      setTimeout(function(){
         animating=false;
     },500);
    }
    
    $('oExpandCollapseText').update(strExpandCollapseText);
    oLink.update(strLinkText);
}

function uncheckedallprobes() {
    $$(".probe_items").each(function(e) {
        e.checked = false;
    });
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
    list_modal.hide();
    list_modal = null;
}

function get_Assign_To_Class_Popup(material_id,material_type)
{
    list_modal = list_modal || null;
    if(list_modal !== null)
    {
        close_popup();
    }
    list_modal = new UI.Window({ theme:"lightbox", width:500, height:460});
    list_modal.setContent("<div style='padding:10px'>Loading...Please Wait.</div>").show(true).focus().center();
    list_modal.setHeader("Assign Materials to a Class");
    
    var options = {
        method: 'post',
        parameters : {'material_type':material_type,'material_id':material_id},
        onSuccess: function(transport) {
            var text = transport.responseText;
            text = "<div id='oErrMsgDiv' style='color:Red;font-weight:bold'></div>"+ text;
            list_modal.setContent("<div style='padding:10px'>" + text + "</div>");
        }
    };
    var target_url = "/search/get_current_material_unassigned_clazzes";
    new Ajax.Request(target_url, options);
}

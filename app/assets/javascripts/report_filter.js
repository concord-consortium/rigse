// Some helpers for toggling checkboxes in the learner and offering reports.
// requires prototype
// requires cookie.js
/*globals $$ createCookie readCookie eraseCookie Form Event*/

function set(parentId, selected) {
  $$(parentId + ' input.filter_checkbox').each(function(box){ box.checked = selected; } );
  return false;
}

function selectAll(parentId) {
  return set(parentId, true);
}

function selectNone(parentId) {
  return set(parentId, false);
}

function autoPrintNextTime() {
  createCookie('auto_print_next_time','true');
}

function autoPrint() {
  var should = readCookie('auto_print_next_time') == 'true';
  eraseCookie('auto_print_next_time');
  if (should) {
    window.print();
  }
}

function areChanges(parentId) {
  var diff = false;
  var last = null;
  var checker = function(box) {
    if (last === null) {
      last = box.checked;
    } else if (last != box.checked) {
      diff = true;
    }
  };
  
  $$(parentId + ' input.filter_checkbox').each(checker);
  return diff;
}

function saveChangesAndPrint(parentId, formId) {
  if (areChanges(parentId)) {
    // submit the form, with autoPrintNextTime
    var actualInput = null;
    var inputs = Form.getInputs($(formId), 'submit');
    inputs.each(function(input) { if (input.value == "Show selected") { actualInput = input; } });
    if (actualInput !== null) {
      autoPrintNextTime();
      actualInput.click();
    }
  } else {
    window.print();
  }
}

Event.observe(window, 'load', function() {
  window.setTimeout("autoPrint();", 3000);
});
function onShowSelected(Event)
{
    var g_showSelected = false;
    $$(".filter_checkbox").each(function(obj){ g_showSelected = g_showSelected || obj.checked;})

    if(!g_showSelected)
    {
        try
        {
            Event.preventDefault();
        }
        catch(e){
            Event.cancelBubble=true;
        }
        
        var description_text = "No questions have been selected."
        showMessagePopup(description_text);
        return false;
    }
    else
    {
        return true;
    }

}


var g_messagePopup = null;

function showMessagePopup(descriptionText)
{
    g_messagePopup = g_messagePopup || null;
    if(g_messagePopup !== null)
    {
        close_popup();
    }
    //alert(descriptionText);
    g_messagePopup = new UI.Window({ resizable: false,theme:"lightbox",width:300,height:125});
    
    var popupHtml = "<div style='padding:10px;padding-left:15px'>" +
                    descriptionText +
                    "</div>" +
                    "<div style = 'margin-left:125px;margin-top:10px' class='msg_popup_ok_button'>" +
                    "<a href=\"javascript:void(0)\" class=\"button\" onclick=\"close_popup()\">OK</a>" +
                    "</div>";
    g_messagePopup.setContent(popupHtml).show(true).focus().center();
    g_messagePopup.setHeader("Message");
    //g_reportLinkPopup.activate();*/
}

function close_popup()
{
    g_messagePopup.destroy();
    g_messagePopup = null;
}

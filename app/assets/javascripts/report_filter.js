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
    var showSelected = false;
    $$(".filter_checkbox").each(function(obj){ showSelected = showSelected || obj.checked;})

    if (showSelected)
    {
        return true;
    }
    
    try
    {
        Event.preventDefault();
    }
    catch(e){
        Event.cancelBubble=true;
    }
    
    var messageText = "No questions have been selected."
    showMessagePopup(messageText);
    return false;
}


function showMessagePopup(messageText)
{
    var popupHtml = "<div style='padding:10px;padding-left:15px'>" +
                    messageText +
                    "</div>";
    
    var lightboxConfig = {
        width:300,
        height:125,
        closeOnNextPopup: true,
        type: Lightbox.type.ALERT,
        content: popupHtml
    };
    
    var messagePopup = new Lightbox(lightboxConfig);
    
    return;
}


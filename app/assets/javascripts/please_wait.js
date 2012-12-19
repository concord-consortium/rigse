var ParseOfferingUrl = function(url) {  
  var offering_id_str = null;
  if (url.match(/portal\/offerings\/\d+\.jnlp/gi)) {
    offering_id_str = url.match(/\d+\.jnlp/gi).first();
    offering_id_str = offering_id_str.match(/\d+/gi).first();
  }
  return offering_id_str;
};

var showWait = (function() { 

  var weAreWiating = function() {
    $('please_wait_message').addClassName('waiting');
    $('please_wait_message').removeClassName('ready');
    $('please_wait_image').show();
    $('please_wait_instructions').hide();
    $('please_wait_report').hide();
  };

  var weAreReady = function() {
    $('please_wait_message').addClassName('ready');
    $('please_wait_message').removeClassName('waiting');
    $('please_wait_image').hide();
    $('please_wait_instructions').show();
    $('please_wait_report').show();
  };

  var updateStatus = function(message) { $('please_wait_message').update(message); };

  var hideWait     = function() { 
    updateStatus('completed');
    $('please_wait').hide();
  };

  var showWait     = function() { $('please_wait').show(); };

  var showCountdownWait = function() {
    var selector = "run_link";
    var waiting_id = null;
    var counting_id = null;
    var counter_dom = 'please_wait_counter';
    var wait_secs = 20;
    var counter = wait_secs;

    weAreWiating();
    var stopCountdown = function() {
      waiting_id = null;
      clearInterval(counting_id);
      counting_id = null;
      weAreReady();
      hideWait();
    };

    var updateCounter = function() {
      $(counter_dom).update(counter);
      counter = counter -1;
    };

    if (waiting_id || counting_id) {  return;  }

    waiting_id = setTimeout(stopCountdown,wait_secs * 1000);
    updateCounter(wait_secs);
    counting_id = setInterval(updateCounter,1000);
    showWait();
  };

  var updateReport = function(offering) {
    var report_dom = 'please_wait_report';
    new Ajax.Updater(report_dom, '/portal/offerings/' + offering +'/student_report.html');
  };


  var showSmartWait = function(offering) {
    var status_id  = null;
    weAreWiating();
    var update_status = function() {
      new Ajax.Request('/portal/offerings/' + offering + '/launch_status.json', {
        method: 'get',
        onSuccess: function(transport) {
          status_event = transport.responseJSON;
          if (!!status_event.event_details) {
            updateStatus(status_event.event_details);
          }
          if (!!status_event && status_event.event_type == "activity_otml_requested") { weAreReady(); }
          if (!!status_id && (status_event.event_type == "bundle_saved" || status_event.event_type == "no_session")) {
            clearInterval(status_id);
            status_id = null;
            updateStatus('completed');
            hideWait();
          }
        },
        onFailure: function() {}
      });
      updateReport(offering);
    };

    updateStatus("Requesting activity launcher...");
    showWait();
    status_id = setInterval(update_status,5000);
  };

  var beginStatusUpdates = function(offering) {
    if (typeof(skipShowWait) == "undefined" || (typeof(skipShowWait) == "boolean" && !skipShowWait)) {
      if (!!offering && typeof(offering) == "string") {
        showSmartWait(offering);
      } else {
        showCountdownWait();
      }
    }
  };
  return beginStatusUpdates;
})();

document.observe("dom:loaded", function() {
  $$(".run_link").each(function(item) {
    if(item.hasClassName('offering')){
      var offering_id = ParseOfferingUrl(item.href);
      item.observe("click", function(e){
        showWait(offering_id);
      });
    } else {
      item.observe("click", showWait);
    }
  });
});

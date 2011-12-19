var showCountdownWait = function() {
  var selector = "run_link";
  var waiting_id = null;
  var counting_id = null;
  var timer_dom = 'counter';
  var wait_dom = 'please_wait';
  var wait_secs = 20;
  var counter = 0;

  var hideWait = function() {
    waiting_id = null;
    clearInterval(counting_id);
    counting_id = null;
    $(timer_dom).update('completed');
    $(wait_dom).hide();
  };

  var update_counter = function() {
    $(timer_dom).update(counter);
    counter = counter -1;
  };
  if (waiting_id || counting_id) {
    return;
  }
  waiting_id = setTimeout(hideWait,wait_secs * 1000);
  $(timer_dom).update(wait_secs);
  counting_id = setInterval(update_counter,1000);
  counter=wait_secs;
  $(wait_dom).show();
};

var showSmartWait = function(offering) {
  var timer_dom = 'counter';
  var wait_dom = 'please_wait';
  var status_id = null;

  var update_status = function() {
    new Ajax.Request('/portal/offerings/' + offering + '/launch_status.json', {
      method: 'get',
      onSuccess: function(transport) {
        status_event = transport.responseJSON;
        if (!!status_event.event_details) {
          $(timer_dom).update("<br/><br/>" + status_event.event_details);
        }

        if (!!status_id && (status_event.event_type == "bundle_saved" || status_event.event_type == "no_session")) {
          clearInterval(status_id);
          status_id = null;
          $(timer_dom).update('completed');
          $(wait_dom).hide();
        }
      },
      onFailure: function() {}
    });
  };

  $(timer_dom).update("<br/><br/>Requesting activity launcher...");
  $(wait_dom).show();
  status_id = setInterval(update_status,5000);
};

var showWait = function(offering) {
  if (!!offering && typeof(offering) == "string") {
    showSmartWait(offering);
  } else {
    showCountdownWait();
  }
};

document.observe("dom:loaded", function() {
  $$(".run_link").each(function(item) {
    item.observe("click", showWait);
  });
});

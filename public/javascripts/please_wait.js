var ParseOfferingUrl = function(url) {
  var offering_id_str = null;
  if (url.match(/portal\/offerings\/\d+\.jnlp/gi)) {
    offering_id_str = url.match(/\d+\.jnlp/gi).first();
    offering_id_str = offering_id_str.match(/\d+/gi).first();
  }
  return offering_id_str;
};

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
  display_mac_10_9_installer_message_if_necessary();
};

is_mac_10_9_or_newer = function() {
  try {
    var version = /Mac OS X 10[\._](\d+)/.exec(window.navigator.userAgent);
    return parseInt(version[1]) >= 9;
  } catch (e) { }
  return false;
}

mac_10_9_message      = '<div style="font-size: 1.1em; color: darkred;">On OS X 10.9 or newer, you will need to install a launcher application in your system in order to run activities. If you have not already installed it, please:<br/>';
mac_10_9_message     += '<ul>';
mac_10_9_message     += '<li><a href="http://static.concord.org/installers/cc_launcher_installer.dmg">Click here</a> to download the launcher installer .dmg</li>';
mac_10_9_message     += '<li>Open the downloaded .dmg and drag the CCLauncher application to your Applications folder</li>';
mac_10_9_message     += '<li>Return to the portal and launch your activity</li>';
mac_10_9_message     += '</ul></div>';

display_mac_10_9_installer_message_if_necessary = function() {
  if (is_mac_10_9_or_newer()) {
    Lightbox.flash("Info", mac_10_9_message);
  }
}

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

(function() {
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
  }

  var update_counter = function() {
    $(timer_dom).update(counter);
    counter = counter -1;
  }
  var showWait = function() {
    if (waiting_id || counting_id) {
      return;
    }
    waiting_id = setTimeout(hideWait,wait_secs * 1000);
    $(timer_dom).update(wait_secs);
    counting_id = setInterval(update_counter,1000);
    counter=wait_secs;
    $(wait_dom).show();
  };

  document.observe("dom:loaded", function() {
    $$("." + selector).each(function(item) {
      item.observe("click", showWait);
    });
  });
}());

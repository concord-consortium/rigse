// function to repair pagination links which break 
// in ajax..

PendingRequests = 0;
PendingTimeout  = 30000;
PendingQue = {};

var repaginate = function(opts) {
  var selector = opts.selector || ".pagination > a";
  var current_url = location.href;
  var links = $$(selector);
  var serialized_data = '';
  //var form = $('investigation_search_form');
  //if (typeof form != 'undefined') {
    //serialized_data=form.serialize();  
    //// &%5B  and %5D= should be stripped. ([]) chars.
    //// rails form helpers inserted those...
    //serialized_data = serialized_data.gsub("&%5B","&");
    //serialized_data = serialized_data.gsub("%5D=","=");
  //}

  var rewrite_link = function(link_elem) {
    var link_text = link_elem.href;
    // take everything after the questionmark
    var query = link_text.replace(/^.*\?/,"");
    current_url = current_url.replace(/\?.*$/,""); // remove previous query
    link_elem.href = current_url + "?" + query + "&" + serialized_data;
  };
  links.each(function(l) { rewrite_link(l);});
};

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
  repaginate({});
};

PendingStart = function(pre,post) {
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
};

PendingEnd = function(post) {
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
};

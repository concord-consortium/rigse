var ParseOfferingUrl = function(url) {
  var offering_id_str = null;
  if (url.match(/portal\/offerings\/\d+\.jnlp/gi)) {
    offering_id_str = url.match(/\d+\.jnlp/gi).first();
    offering_id_str = offering_id_str.match(/\d+/gi).first();
  }
  return offering_id_str;
};

var Workgroup = function(_offering) {
  var learners_list      = null;
  var learners_dropdown  = null;
  var add_button         = null;
  var run_button         = null;
  var add_group          = null;
  var learners_container = null;
  var lightbox_hood      = null;
  var lightbox_content   = null;
  var learners           = [];
  var collaborators      = [];
  var offering           = _offering;

  var learner_id_for = function(learner) { return "_LEARNER_" + learner.id; };
  
  var load_dom_elems = function() {
    if (learners_list == null) {
      learners_list      =  $('learners_list');
      learners_dropdown  =  $('learners_dropdown');
      add_button         =  $('add_button');
      run_button         =  $('run_button');
      add_group          =  $('add_group');
      learners_container =  $('learners_container');
      lightbox_hood      =  $('lightbox_hood');
      lightbox_content   =  $('lightbox_content');
    }
  };

  var show_workgroup_editor = function() {
    $('workgroup_panel').show();
    $('show_workgroups').up().hide();
    $('load_wait').show();
  };

  var close_dialog = function() {
    lightbox_hood.hide();
    lightbox_content.hide();
    $(document).stopObserving('keydown');
  };

  var launch_action = function() {
    //window.location = "/portal/workgroups/offering/" + offering_id + "/start";
    new Ajax.Request('/portal/offerings/' + offering + '/start.json', {
      parameters: { students: collaborators.map(function(l){return l.id;}).join(',')  },
      onSuccess: function() { 
        console.log('sucess');  
        close_dialog();
        window.location = "/portal/offerings/" + offering + ".jnlp"
      },
      onFaiulre: function() { console.log('failure'); }
    });
    //close_dialog();
  };
 
  var handle_keydown = function(e) {
    var code;
    if (!e) var e = window.event;
    if (e.keyCode) code = e.keyCode;
    else if (e.which) code = e.which;
    switch (code) {
      case 27: 
        handle_escape(e);
        break;
      case 13:
        handle_return(e);
        break;
      default:
    }
  };

  var handle_escape = function(e) { close_dialog(); };

  var handle_return = function(e) { };

  // startup
  var load = function() {
    load_dom_elems();
    learners = [];
    collaborators = [];
    load_learners();
    add_button.observe('click',function() { 
      add_learner(selected_learner());
    });
    run_button.observe('click', launch_action);
    $(document).observe('keydown', handle_keydown);
    $('show_workgroups').observe('click',show_workgroup_editor);
    lightbox_hood.show();
    lightbox_content.show();
  };

  var add_learner = function(learner) {
    learners = learners.without(learner);
    learners = learners.sortBy(function(e) {return e.name;} );
    collaborators.push(learner);
    collaborators = collaborators.sortBy(function(e) {return e.name;} );
    update_ui();
  };

  var remove_learner = function(learner) {
    collaborators = collaborators.without(learner).sortBy(function(e) {return e.name;} );
    learners.push(learner);
    learners = learners.sortBy(function(e) {return e.name;} );
    update_ui();
  };

  var selected_learner = function() {
    selected = learners_dropdown.select('option').find(function(ele){return !!ele.selected});
    var learner = learners.detect(function(l) {
      return l.id == parseInt(selected.value);
    });
    return learner;
  };

  // return learners in this learners class
  var load_learners = function() {
    learners = []; //remove last
    new Ajax.Request('/portal/offerings/' + offering + '/learners.json', {
      method: 'get',
      onSuccess: function(transport) {
        learners = transport.responseJSON;
        learners = learners.sortBy(function(l) {return l.name});
        $('load_wait').hide();
        update_ui();
      },
      onFailure: function() { }
    });
  };

  var add_learner_to_container = function(learner) {
    var template       = $('learner_template');
    var learner_el     = Element.clone(template,true);
    var name_field     = learner_el.select('.name_field').first();
    var delete_button  = learner_el.select('.delete').first();
    var password_field = learner_el.select('.password_field').first();
    var login_button   = learner_el.select('.login_button').first();
    var pending        = learner_el.select('.pending').first();
    var complete       = learner_el.select('.complete').first();
    var login_failed   = learner_el.select('.fail').first();
    var wait           = learner_el.select('.wait').first();

    name_field.update(learner.name);
    learner_el.id = learner_id_for(learner);
    learners_list.insert({ bottom: learner_el});

    if (learner.have_consent) { pending.hide();  }
    else                      { complete.hide(); }

    delete_button.observe('click',function() {remove_learner(learner);});
    login_failed.hide();
    wait.hide();

    var login_success = function() {
      learner.have_consent = true;
      login_button.stopObserving();
      pending.hide();
      login_failed.hide();
      wait.hide();
      complete.show();
      update_ui();
    };

    var login_failure = function() {
      login_failed.show();
      wait.hide();
      pending.show();
      update_ui();
    }

    login_button.observe('click',function() {
      pending.hide();
      wait.show();
      check_password(learner,password_field.value, login_success,login_failure);
    });
  };

  var remove_learner_from_container = function(learner) {
    var learner_dom = $(learner_id_for(learner));
    if (learner_dom) {
      learner_dom.remove();
    }
  };

  var clear_containers = function() {
    learners_dropdown.select('.learner').each(function(e) { e.remove(); });
    learners_container.select('.learner').each(function(e) {e.remove();});
  };

  var update_ui = function() {
    run_button.show();
    clear_containers();
    learners.each(function(learner) {
      add_learner_to_dropdown(learner);
    });
    collaborators.each(function(learner){
      add_learner_to_container(learner);
      if (!learner.have_consent) {
        run_button.hide();
      }
    });
    if (collaborators.size() < 1) {
      learners_container.hide();
    }
    else {
      learners_container.show();
    }
    if (learners.size() < 1) {
      add_group.hide();
    }
    else {
      add_group.show();
    }
  };

  var add_learner_to_dropdown = function (learner) {
    var learner_el = new Element('option',
      {
        'class': 'learner',
        id: learner_id_for(learner),
        value: learner.id
      }).update(learner.name);
    learners_dropdown.insert({ bottom: learner_el})
  };

  var remove_learner_from_dropdown = function (learner) {
    var id = learner_id_for(learner,"dropdown");
    var learner_dom = $(id);
    if (learner_dom) {
      $(id).remove();
    }
  };

  var check_password = function(learner,passwd,succ,fail) {
    new Ajax.Request('/portal/offerings/' + offering + '/check_learner_auth', {
      parameters: {'learner_id': learner.id, 'pw': passwd},
      onSuccess: function(transport) { succ.call(); } ,
      onFailure: function()          { fail.call(); } 
    });
  };

  load();
};

document.observe("dom:loaded", function() {
  $$('a.run_link').each(function(el) {
    var offering_id = ParseOfferingUrl(el.href);
    console.log("found offering: " + offering_id);
    //el.observe('click',load(208));
    el.observe('click', function(e) {
      Workgroup(offering_id);
      e.stop();
    });
  });
});

var ParseOfferingUrl = function(url) {
  var offering_id_str = null;
  if (url.match(/portal\/offerings\/\d+\.jnlp/gi)) {
    offering_id_str = url.match(/\d+\.jnlp/gi).first();
    offering_id_str = offering_id_str.match(/\d+/gi).first();
  }
  return offering_id_str;
};

var EnableWorkgroups = function(_selector) {
  _selector = _selector ||   'a.run_link';
    $$(_selector).each(function(el) {
    var offering_id = ParseOfferingUrl(el.href);
    // remove other click observers!
    el.stopObserving('click');
    el.observe('click', function(e) {
      Workgroup(offering_id);
      e.stop();
    });
  });
};

var Workgroup = function(_offering) {
  var load_error         = false;
  var loading_learners   = false;
  var learners           = [];
  var collaborators      = [];
  var offering           = _offering;
  var pending_requests   = 0;

  // TODO: move me to a view-class
  var learners_list      = null;
  var learners_dropdown  = null;
  var add_button         = null;
  var run_button         = null;
  var run_message        = null;
  var add_group          = null;
  var learners_container = null;
  var lightbox_hood      = null;
  var lightbox_content   = null;

  var learner_id_for = function(learner) { return "_LEARNER_" + learner.id; };

  var load_dom_elems = function() {
    if (learners_list === null) {
      learners_list      =  $('learners_list');
      learners_dropdown  =  $('learners_dropdown');
      add_button         =  $('add_button');
      run_button         =  $('run_button');
      run_message        =  $('run_message');
      add_group          =  $('add_group');
      learners_container =  $('learners_container');
      lightbox_hood      =  $('lightbox_hood');
      lightbox_content   =  $('lightbox_content');
    }
  };

  var show_workgroup_editor = function() {
    load_learners();
    $('workgroup_panel').show();
    $('show_workgroups').up().hide();
  };

  var hide_workgroup_editor = function() {
    $('workgroup_panel').hide();
    $('show_workgroups').up().show();
  };

  var close_dialog = function() {
    var timeout = null;
    // we have to undo all our setup here:
    // show wait
    var closefunction = function() {
      learners = [];
      collaborators= [];
      update_ui();  // this will remove and hide dom elements
      loading_learners = true; 
      if (pending_requests < 1) {
        lightbox_hood.hide();
        lightbox_content.hide();
        hide_workgroup_editor();
        clearTimeout(timeout);
        $(document).stopObserving('keydown');
      }
    };
    timeout = setTimeout(function(){closefunction();}, 100);
  };

  var launch_action = function() {
    pending_requests = pending_requests +1;
    lightbox_hood.hide();
    lightbox_content.hide();
    showWait(offering);
    new Ajax.Request('/portal/offerings/' + offering + '/start.json', {
      parameters: { students: collaborators.map(function(l){return l.id;}).join(',')  },
      onSuccess: function() {
        pending_requests = pending_requests -1;
        close_dialog();
        window.location = "/portal/offerings/" + offering + ".jnlp"
      },
      onFailure: function() {
        pending_requests = pending_requests -1;
      }
    });
  };

  var handle_keydown = function(e) {
    var code;
    if (!e) e = window.event;
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
        break;
    }
  };

  var handle_escape = function(e) { close_dialog(); };

  var handle_return = function(e) { };

  // startup
  var load = function() {
    load_dom_elems();
    learners = [];
    collaborators = [];
    $(document).observe('keydown', handle_keydown);
    $('show_workgroups').observe('click',show_workgroup_editor);
    $('cancel_button').observe('click',close_dialog);
    lightbox_hood.show();
    lightbox_content.show();
    update_ui();
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

  var disable_run = function() {
    run_button.setOpacity(0.3);
    run_message.update('enter valid passwords for all collaborators');
    run_message.addClassName('wg_important');
    run_button.stopObserving('click');
  };

  var enable_run = function() {
    run_button.setOpacity(1);
    run_message.update('run the activity now');
    run_message.removeClassName('wg_important');
    run_button.stopObserving('click');
    run_button.observe('click', launch_action);
  };

  var disable_add = function() {
    add_button.setOpacity(0.5);
    add_button.stopObserving('click');
  };

  var enable_add = function() {
    add_button.setOpacity(1);
    add_button.stopObserving('click'); //clear older handlers
    add_button.observe('click',function(e) { add_learner(selected_learner()); });
  };

  var selected_learner = function() {
    selected = learners_dropdown.select('option').find(function(ele){return !!ele.selected;});
    var learner = learners.detect(function(l) {
      return l.id == parseInt(selected.value, 10);
    });
    return learner;
  };


  // return learners in this learners class
  var load_learners = function() {
    learners = []; //remove last
    load_error = false;
    loading_learners = true;
    update_ui();
    pending_requests = pending_requests + 1;
    new Ajax.Request('/portal/offerings/' + offering + '/learners.json', {
      method: 'get',
      onSuccess: function(transport) {
        learners = transport.responseJSON;
        learners = learners.sortBy(function(l) {return l.name;});
        loading_learners = false;
        load_error = false;
        pending_requests = pending_requests - 1;
        update_ui();
      },
      onFailure: function() {
        load_error = true;
        loading_learners = false;
        pending_requests = pending_requests - 1;
        update_ui();}
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
    var do_check_password = function() {
      pending.hide();
      wait.show();
      check_password(learner,password_field.value, login_success,login_failure);
    };
    login_button.observe('click',do_check_password);
    password_field.observe('keydown',function(e) {
        var code;
        if (!e) e = window.event;
        if (e.keyCode) code = e.keyCode;
        else if (e.which) code = e.which;
        switch (code) {
          case 13:
            do_check_password();
            break;
          default:
            break;
        }
    });

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
    };

  };

  var remove_learner_from_container = function(learner) {
    var learner_dom = $(learner_id_for(learner));
    if (learner_dom) {
      learner_dom.remove();
    }
  };

  var clear_containers = function() {
    learners_dropdown.select('.learner').each(function(e) { e.remove(); });
    learners_container.select('.learner').each(function(e){ e.remove();});
  };

  var reset_visual_state = function() {
    clear_containers();
    enable_run();
    enable_add();
    add_group.show();
    learners_container.show();
    $('load_wait').hide();
    $('load_error').hide();
  };

  var update_ui = function() {
    reset_visual_state();
    learners.each(function(learner) { add_learner_to_dropdown(learner); });
    collaborators.each(function(learner){
      add_learner_to_container(learner);
      if (!learner.have_consent) {
        disable_run();
      }
    });

    if (pending_requests > 1)     { disable_run(); disable_add();            }
    if (collaborators.size() < 1) { learners_container.hide();               }
    if (loading_learners)         { add_group.hide(); $('load_wait').show(); }
    if (load_error)               { $('load_error').show();                  }
  };

  var add_learner_to_dropdown = function (learner) {
    var learner_el = new Element('option',
      {
        'class': 'learner',
        id: learner_id_for(learner),
        value: learner.id
      }).update(learner.name);
    learners_dropdown.insert({ bottom: learner_el});
  };

  var remove_learner_from_dropdown = function (learner) {
    var id = learner_id_for(learner,"dropdown");
    var learner_dom = $(id);
    if (learner_dom) {
      $(id).remove();
    }
  };

  var check_password = function(learner,passwd,succ,fail) {
    pending_requests = pending_requests + 1;
    new Ajax.Request('/portal/offerings/' + offering + '/check_learner_auth', {
      parameters: {'learner_id': learner.id, 'pw': passwd},
      onSuccess: function(transport) {
        pending_requests = pending_requests - 1;
        succ.call();
      } ,
      onFailure: function() {
        pending_requests = pending_requests - 1;
        fail.call();
      }
    });
  };
  load();
};

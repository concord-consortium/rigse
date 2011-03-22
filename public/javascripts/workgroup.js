(function() {
  var add_learner_button = null;
  var learners_list = null;
  var learners_dropdown = null;
  var add_button = null;
  var run_button = null;
  var learners = null;
  var collaborators = null;
  var password_panel = null;
  var login_button = null;
  var login_user_name = null;
  var password_field = null;

  // startup
  var load_workgroups = function() {
  var lightbox_hood      = null;
  var lightbox_content   = null;
    add_learner_button = $('add_learner');
    learners_container = $('learners_container');
    learners_list = $('learners_list');
    learners_dropdown  = $('learners_dropdown');
    add_button = $('add_button');
    add_group  = $('add_group');
    password_panel = $('password_panel');
    login_button =   $('login_button');
    login_user_name = $('login_user_name');
    password_field =  $('password_field');
    run_button =$('run_button');
    lightbox_hood      = $('lightbox_hood');
    lightbox_content   = $('lightbox_content');
    collaborators = [];
    learners = [];
    add_button.observe('click',function() {add_learner(selected_learner()); });
    $('show_workgroups').observe('click', function() { 
      $('workgroup_panel').toggle();
      load_learners();
      $('show_workgroups').up().hide();
      $('load_wait').show();
    });
    lightbox_hood.show();
    lightbox_content.show();
  };

  var close_workgroups = function() {
    lightbox_hood.hide();
    lightbox_content.hide();
    console.log("here is where we dream big...");
    console.log()
    //window.setLocation();
  }
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
    new Ajax.Request('/portal/offerings/208/learners.json', {
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


  var learner_id_for = function(learner) {
    return "_LEARNER_" + learner.id;
  };

  var password_field_for = function(learner) {
    password_panel.show();
    login_user_name.update(learner.name);
    login_button.observe('click', function() {
      var passwd = password_field.value;
      if(check_password(learner,passwd)) {
        learner.have_consent = true;
        login_button.stopObserving();
        password_panel.hide();
        callback.call();
        update_ui();
        return true;
      }
      else {
        learner.have_consent = false;
        login_button.stopObserving();
        password_panel.hide();
        return false;
      }
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

    if (learner.have_consent) {
      pending.hide();
    }
    else {
      complete.hide();
    }
    delete_button.observe('click',function() {remove_learner(learner);});
    login_failed.hide();
    wait.hide();
    var success = function() {
      learner.have_consent = true;
      login_button.stopObserving();
      pending.hide();
      login_failed.hide();
      wait.hide();
      complete.show();
      update_ui();
    };
    var failure = function() {
      login_failed.show();
      wait.hide();
      pending.show();
      update_ui();
    }
    login_button.observe('click',function() {
      pending.hide();
      wait.show();
      check_password(learner,password_field.value, success,failure);
    });
  };

  var remove_learner_from_container = function(learner) {
    var learner_dom = $(learner_id_for(learner));
    if (learner_dom) {
      learner_dom.remove();
    }
  };


  var update_ui = function() {
    run_button.show();
    learners.each(function(learner) {
      remove_learner_from_container(learner);
      add_learner_to_dropdown(learner);
    });
    collaborators.each(function(learner){
      remove_learner_from_dropdown(learner);
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
    new Ajax.Request('/portal/offerings/208/check_learner_auth', {
      parameters: {'learner_id': learner.id, 'pw': passwd},
      onSuccess: function(transport) {
        succ.call();
      },
      onFailure: function() {fail.call();}
    });

    //if (passwd == 'password') {
      //succ.call();
    //}
    //else {
      //fail.call();
    //}
  };

  document.observe("dom:loaded", function() {
    $$('.run_link').each(function(el) {
      el.observe('click',load_workgroups());
    });
    load_workgroups();
  });

}());

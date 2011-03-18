//(function()
  console.log("loading");
  var add_learner_button = null;
  var learners_list = null;
  var learners_dropdown = null;
  var add_button = null;
  var learners = null;
  var password_panel = null;
  var login_button = null;
  var login_user_name = null;
  var password_field = null;

  // startup
  var initialize_workgroup_ui = function() {
    console.log("here we go");
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
    add_button.observe('click',add_learner);
    learners = get_learners();
    learners.each (function(l) { add_learner_to_dropdown(l); });
    check_visibility();
  };

  var do_add_learner = function(learner) {
    if(learner.have_consent) {
      add_learner_to_list(learner);
      remove_learner_from_dropdown(learner);
      check_visibility();
    }
  };

  var add_learner = function(button) {
    selected = learners_dropdown.select('option').find(function(ele){return !!ele.selected});
    var learner = learners.detect(function(l) {
      return l.id == parseInt(selected.value);
    });
    if (learner.have_consent) {
      do_add_learner(learner);
    }
    else {
      ask_password(learner, function() {
        do_add_learner(learner);
      });
    }
  };

  // return learners in this learners class
  var get_learners = function() {
    // var learners = ajax.get('blah')
    var _learners = [
      { name: 'John Doe',      id: 1, in_group: false, have_consent: false},
      { name: 'Jane Doe',      id: 2, in_group: false, have_consent: false},
      { name: 'Mark Schard',   id: 3, in_group: false, have_consent: false},
      { name: 'Linda Low',     id: 4, in_group: false, have_consent: false},
      { name: 'Steve Austin',  id: 5, in_group: false, have_consent: false},
      { name: 'Dexter Tron',   id: 6, in_group: false, have_consent: false},
      { name: 'Abraham Leaf',  id: 7, in_group: false, have_consent: false},
      { name: 'Ada Paessel',   id: 8, in_group: false, have_consent: false},
      { name: 'Linden Paessel', id: 9, in_group: false, have_consent: false},
      { name: 'Dan Damian',    id: 10, in_group: false, have_consent: false}
    ]
    _learners = _learners.sortBy(function(e) {return e.name;} );
    return _learners;
  };


  var learner_id_for = function(learner,scope) {
    return "_LEARNER_" + scope + learner.id;
  };

  var add_learner_to_list = function(learner) {
    learner.in_group = true;
    var learner_el = new Element('li',
      {
        'class': 'learner',
        id: learner_id_for(learner,'container'),
        value: learner.i,
      }).update(learner.name);
    var delete_button = new Element('span', {
      'class': 'delete',
      id: learner_id_for(learner,'remove'),
    }).update('remove');
    learners_list.insert({ bottom: learner_el});
    learner_el.insert({bottom: delete_button});
    delete_button.observe('click',function() {remove_learner_from_container(learner);});
  };

  var remove_learner_from_container = function(learner) {
    learner.in_group = false;
    $(learner_id_for(learner,'container')).remove();
    add_learner_to_dropdown(learner);
    var selected = learners.select(function(e) { return e.in_group == true});
    check_visibility();
  };
 
  var check_visibility = function() {
    var selected = learners.select(function(e) { return e.in_group == true});
    var not_selected = learners.select(function(e) { return e.in_group == false});
    if (selected.size() < 1) { 
      learners_container.hide(); 
    }
    else {
      learners_container.show();
    }
    if (not_selected.size() < 1) { 
      add_group.hide(); 
    }
    else {
      add_group.show();
    }
  };
  
  var add_learner_to_dropdown = function (learner) {
    learner.in_group = false;
    var learner_el = new Element('option',
      {
        'class': 'learner',
        id: learner_id_for(learner,'dropdown'),
        value: learner.id
      }).update(learner.name);
    learners_dropdown.insert({ bottom: learner_el})
  };

  var remove_learner_from_dropdown = function (learner) {
    var id = learner_id_for(learner,"dropdown");
    $(id).remove();
  };
  
  var check_password = function(learner,passwd) {
    if (passwd == 'password') {
      return true;
    }
    return false;
  };

  var ask_password = function(learner,callback) {
    password_panel.show();
    login_user_name.update(learner.name);
    login_button.observe('click', function() {
      var passwd = password_field.value;
      if(check_password(learner,passwd)) {
        learner.have_consent = true;
        login_button.stopObserving();
        password_panel.hide();
        callback.call();
        return true;
      }
      else {
        learner.have_consent = false;
        login_button.stopObserving();
        password_panel.hide();
        return false;
      }
    });
  }

  document.observe("dom:loaded", function() {
    console.log("Yup here we go");
    initialize_workgroup_ui();
    console.log("Yup there we went");
  });

//}());

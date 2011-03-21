//(function()
  var add_learner_button = null;
  var learners_list = null;
  var learners_dropdown = null;
  var add_button = null;
  var learners = null;
  var collaborators = null;
  var password_panel = null;
  var login_button = null;
  var login_user_name = null;
  var password_field = null;

  // startup
  var initialize_workgroup_ui = function() {
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
    add_button.observe('click',function() {add_learner(selected_learner()); });
    learners = get_learners();
    collaborators = [];
    learners.each (function(l) { add_learner_to_dropdown(l); });
    update_ui();
  };

  var add_learner = function(learner) {
    if(learner.have_consent) {
      learners = learners.without(learner);
      learners = learners.sortBy(function(e) {return e.name;} );
      collaborators.push(learner);
      collaborators = collaborators.sortBy(function(e) {return e.name;} );
      update_ui();
    }
    else {
      ask_password(learner,function() {
        add_learner(learner);
      });
    }
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
  var get_learners = function() {
    // var learners = ajax.get('blah')
    var _learners = [
      { name: 'John Doe',      id: 1,  have_consent: false},
      { name: 'Jane Doe',      id: 2,  have_consent: false},
      { name: 'Mark Schard',   id: 3,  have_consent: false},
      { name: 'Linda Low',     id: 4,  have_consent: false},
      { name: 'Steve Austin',  id: 5,  have_consent: false},
      { name: 'Dexter Tron',   id: 6,  have_consent: false},
      { name: 'Abraham Leaf',  id: 7,  have_consent: false},
      { name: 'Ada Paessel',   id: 8,  have_consent: false},
      { name: 'Linden Paessel', id: 9, have_consent: false},
      { name: 'Dan Damian',    id: 10, have_consent: false}
    ]
    _learners = _learners.sortBy(function(e) {return e.name;} );
    return _learners;
  };


  var learner_id_for = function(learner) {
    return "_LEARNER_" + learner.id;
  };

  var add_learner_to_container = function(learner) {
    var learner_el = new Element('li',
      {
        'class': 'learner',
        id: learner_id_for(learner),
        value: learner.i,
      }).update(learner.name);
    var delete_button = new Element('span', {
      'class': 'delete'
    }).update('remove');
    learners_list.insert({ bottom: learner_el});
    learner_el.insert({bottom: delete_button});
    delete_button.observe('click',function() {remove_learner(learner);});
  };

  var remove_learner_from_container = function(learner) {
    var learner_dom = $(learner_id_for(learner));
    if (learner_dom) {
      learner_dom.remove();
    }
  };


  var update_ui = function() {
    learners.each(function(learner) {
      remove_learner_from_container(learner);
      add_learner_to_dropdown(learner);
    });
    collaborators.each(function(learner){
      remove_learner_from_dropdown(learner);
      add_learner_to_container(learner);
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
    initialize_workgroup_ui();
  });

//}());

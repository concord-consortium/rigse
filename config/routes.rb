ActionController::Routing::Routes.draw do |map|
  map.namespace(:saveable) do |saveable|
    saveable.namespace(:sparks) do |sparks|
      sparks.resources :measuring_resistances
      sparks.resources :measuring_resistance_reports
    end
  end


#
# ********* New scoped routing for page-embeddables, probes, and RI GSEs  *********
#
#            delete the older routes by hand!
#


  map.namespace(:probe) do |probe|
    probe.resources :vendor_interfaces
    probe.resources :probe_types
    probe.resources :physical_units
    probe.resources :device_configs
    probe.resources :data_filters
    probe.resources :calibrations
  end

  map.namespace(:ri_gse) do |ri_gse|
    ri_gse.resources :assessment_targets, :knowledge_statements, :domains
    ri_gse.resources :big_ideas, :unifying_themes, :expectations, :expectation_stems
    ri_gse.resources :grade_span_expectations, 
      :collection => { 
        :select_js => :post,
        :summary => :post,
        :reparse_gses => :put,
        :select => :get }, 
      :member => { :print => :get }
  end

  map.namespace(:embeddable) do |embeddable|

    embeddable.namespace(:smartgraph) do |smartgraph|
      smartgraph.resources :range_questions
    end

    embeddable.namespace(:biologica) do |biologica|
      biologica.resources :chromosome_zooms, :member => { :destroy => :post }
      biologica.resources :multiple_organisms, :member => { :destroy => :post }
      biologica.resources :breed_offsprings, :member => { :destroy => :post }
      biologica.resources :meiosis_views, :member => { :destroy => :post }
      biologica.resources :chromosomes, :member => { :destroy => :post }
      biologica.resources :pedigrees, :member => { :destroy => :post }
      biologica.resources :static_organisms, :member => { :destroy => :post }
      biologica.resources :organisms, :member => { :destroy => :post }
      biologica.resources :worlds, :member => { :destroy => :post }
    end

    embeddable.resources :inner_pages, :member => {
      :destroy => :post,
      :add_page => :post,
      :add_element => :post,
      :set_page => :post,
      :sort_pages => :post, 
      :delete_page => :post
    }

    embeddable.resources :lab_book_snapshots, :member => { :destroy => :post }

    embeddable.resources :raw_otmls, :member => { :destroy => :post }

    embeddable.resources :n_logo_models, :member => { :destroy => :post }
    embeddable.resources :mw_modeler_pages, :member => { :destroy => :post }

    embeddable.resources :data_tables, :member => {
      :print => :get,
      :destroy => :post,
      :update_cell_data => :post
    }

    embeddable.resources :multiple_choices, :member => {
      :print => :get,
      :destroy => :post,
      :add_choice => :post
    }

    embeddable.resources :drawing_tools, :member => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :xhtmls, :member => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :open_responses, :member  => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :data_collectors, :member => {
      :print => :get,
      :destroy => :post,
      :change_probe_type => :put
    }
    
    embeddable.resources :sound_graphers, :member => {
      :destroy => :post
    }

    embeddable.resources :image_questions, :member => {
      :destroy => :post
    }
    embeddable.resources :video_players, :member => {
      :destroy => :post
    }
  end

# ********* end of scoped routing for page-embeddables, probes, and RI GSEs  *********

  map.namespace(:smartgraph) do |smartgraph|
    smartgraph.resources :range_questions
  end

  map.namespace(:portal) do |portal|
    portal.resources :clazzes, :as => 'classes', :member => {
        :add_offering => [:get,:post],
        :add_student => [:get, :post],
        :remove_offering => [:get, :post],
        :edit_offerings => [:get,:post],
        :add_teacher => [:post],
        :remove_teacher => [:delete]
    }
    portal.resources :clazzes do |clazz|
      clazz.resources :student_clazzes
    end
    portal.resources :courses
    portal.resources :districts, :member => { :destroy => :post }
    portal.resources :grades
    portal.resources :grade_levels
    portal.resources :learners,  :member => { 
      :report => :get,
      :open_response_report => :get, 
      :multiple_choice_report => :get,
      :bundle_report => :get
    }
    portal.resources :offerings, :member => { 
      :report => :get,
      :open_response_report => :get, 
      :multiple_choice_report => :get 
    }, :collection => { :data_test => [:get,:post] }

    # TODO: Totally not restful.  We should change
    # all routes to use :delete, and then modify
    # the delete_button in application controller
    # to use :method => :delete
    portal.resources :schools, :member => { :destroy => :post }
    portal.resources :school_memberships
    portal.resources :semesters
    portal.resources :students, :collection => {
      :signup => [:get],
      :register => [:get, :post]
    }
    portal.resources :student_clazzes, :as => 'student_classes'
    portal.resources :subjects
    portal.resources :teachers
    
    portal.resources :external_user_domains
    portal.resources :external_users
    
    portal.resources :nces06_districts
    portal.resources :nces06_schools
    # portal.home 'readme', :controller => 'home', :action => 'readme'  
    # oops no controller for home any more, see http://www.pivotaltracker.com/story/show/2605204
  end
  
  

  
  # Restful Authentication Rewrites
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.linktool '/linktool', :controller => 'sakai_link', :action => 'index'
  map.fake_verification '/sakai-axis/SakaiSigning.jws', :controller => 'sakai_link', :action => 'fake_verification'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'login'
  map.forgot_password_email '/forgot_password/email', :controller => 'passwords', :action => 'email'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.password_questions '/password/:user_id/questions', :controller => 'passwords', :action => 'questions'
  map.check_password_questions '/password/:user_id/check_questions', :controller => 'passwords', :action => 'check_questions'
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }

  # Restful Authentication Resources
  map.resources :users, :member => { 
      :preferences => [:get, :put], 
      :switch => [:get, :put], 
      :interface => :get,
      :suspend   => :put,
      :unsuspend => :put,
      :purge     => :delete } do |users|
    users.resource :security_questions, :only => [ :edit, :update ]
  end
  map.users_account_report '/users/reports/account_report', :controller => 'users', :action => 'account_report', :method => :get

  map.resources :passwords
  map.resource :session

  map.resources :external_user_domains do |external_user_domain|
    external_user_domain.resources :external_users    
    external_user_domain.resources :external_sessions
  end

# ----------------------------------------------

  map.namespace(:dataservice) do |dataservice|
    dataservice.resources :blobs
    dataservice.resources :bundle_contents
    dataservice.resources :bundle_loggers do |bundle_logger|
      bundle_logger.resources :bundle_contents
    end
    dataservice.resources :console_contents
    dataservice.resources :console_loggers do |console_logger|
      console_logger.resources :console_contents
    end
    
  end
  
  # FIXME not sure how to map this within the dataservice namespace above...
  map.dataservice_blob_raw "dataservice/blobs/:id.blob/:token", :controller => "dataservice/blobs", :action => "show", :format => "blob", :requirements => { :id => /\d+/, :token => /[a-zA-Z0-9]{32}/ } 

  map.namespace(:admin) do |admin|
    admin.resources :projects, :member => { :update_form => :put }
  end

  map.namespace(:maven_jnlp) do |maven_jnlp|
    maven_jnlp.resources :native_libraries
    maven_jnlp.resources :jars
    maven_jnlp.resources :properties
    maven_jnlp.resources :versioned_jnlps
    maven_jnlp.resources :versioned_jnlp_urls
    maven_jnlp.resources :icons
    maven_jnlp.resources :maven_jnlp_families
    maven_jnlp.resources :maven_jnlp_servers
  end


  map.namespace(:otrunk_example) do |otrunk_example|
    otrunk_example.resources :otrunk_imports
    otrunk_example.resources :otml_categories
    otrunk_example.resources :otml_files
    otrunk_example.resources :otrunk_view_entries
  end

  map.resources :teacher_notes
  map.resources :author_notes
  
  
#
# ********* Start of Page embeddable objects *********
#

  map.resources :lab_book_snapshots, :member => { :destroy => :post }

  map.resources :inner_pages, :member => {
    :destroy => :post,
    :add_page => :post,
    :add_element => :post,
    :set_page => :post,
    :sort_pages => :post, 
    :delete_page => :post
  }

  map.resources :biologica_chromosome_zooms, :member => { :destroy => :post }
  map.resources :biologica_multiple_organisms, :member => { :destroy => :post }
  map.resources :biologica_breed_offsprings, :member => { :destroy => :post }
  map.resources :biologica_meiosis_views, :member => { :destroy => :post }
  map.resources :biologica_chromosomes, :member => { :destroy => :post }
  map.resources :biologica_pedigrees, :member => { :destroy => :post }
  map.resources :biologica_static_organisms, :member => { :destroy => :post }
  map.resources :biologica_organisms, :member => { :destroy => :post }
  map.resources :biologica_worlds, :member => { :destroy => :post }

  map.resources :raw_otmls, :member => { :destroy => :post }

  map.resources :n_logo_models, :member => { :destroy => :post }
  map.resources :mw_modeler_pages, :member => { :destroy => :post }

  map.resources :data_tables, :member => {
    :print => :get,
    :destroy => :post,
    :update_cell_data => :post
  }

  map.resources :multiple_choices, :member => {
    :print => :get,
    :destroy => :post,
    :add_choice => :post
  }

  map.resources :drawing_tools, :member => {
    :print => :get,
    :destroy => :post
  }

  map.resources :xhtmls, :member => {
    :print => :get,
    :destroy => :post
  }
  
  map.resources :open_responses, :member  => {
    :print => :get,
    :destroy => :post
  }

  map.resources :data_collectors, :member => {
    :print => :get,
    :destroy => :post,
    :change_probe_type => :put
  }

  map.resources :sections, :member => {
    :destroy => :post,
    :add_page => [:post, :get],
    :sort_pages => :post, 
    :delete_page => :post,
    :print => :get,
    :duplicate => :get
  }
    
  map.resources :pages, :member => {
    :destroy => :post,
    :add_element => :post,
    :sort_elements => :post,
    :delete_element => :post,
    :paste  => :post,
    :paste_link => :post,
    :preview => :get,
    :print => :get,
    :duplicate => :get
  }

#
# ********* End of Page embeddable objects *********
#

  map.resources :pages do |page|
    page.resources :xhtmls
    page.resources :open_responses
    page.resources :data_collectors
  end
  
  map.resources :page_elements, :member => {
    :destroy => :post
  }

  map.resources :investigations, :member => {
    :add_activity => :post,
    :sort_activities => :post,
    :delete_activity => :post,
    :print => :get,
    :duplicate => :get,
    :export => :get,
    :details_report => :get,
    :usage_report => :get,
    :destroy => :post
  }
  map.investigation_preview_list '/investigations/list/preview/', :controller => 'investigations', :action => 'preview_index', :method => :get
  map.list_filter_investigation '/investigations/list/filter', :controller => 'investigations', :action => 'index', :method => :post
  map.investigation_teacher_otml '/investigations/teacher/:id.otml', :controller => 'investigations', :action => 'teacher', :method => :get, :format => :otml
  map.investigation_teacher_dynamic_otml '/investigations/teacher/:id.dynamic_otml', :controller => 'investigations', :action => 'teacher', :method => :get, :format => :dynamic_otml
  
  map.investigation_usage_report '/investigations/reports/usage', :controller => 'investigations', :action => 'usage_report', :method => :get
  map.investigation_details_report '/investigations/reports/details', :controller => 'investigations', :action => 'details_report', :method => :get
  
  map.resources :activities, :member => {
    :add_section => [:post,:get],
    :sort_sections => :post,
    :delete_section => :post,
    :print => :get,
    :duplicate => :get,
    :export => :get,
    :destroy => :post
  }
  map.list_filter_activity '/activity/list/filter', :controller => 'activities', :action => 'index', :method => :post
  #map.investigation_teacher_otml '/investigations/teacher/:id.otml', :controller => 'investigations', :action => 'teacher', :method => :get, :format => :otml
  #map.investigation_teacher_dynamic_otml '/investigations/teacher/:id.dynamic_otml', :controller => 'investigations', :action => 'teacher', :method => :get, :format => :dynamic_otml
  

  map.resources :activities do |activity|
    activity.resources :sections do |section|
      section.resources :pages do |page|
        page.resources :page_elements
      end
    end
  end

  map.resources :assessment_targets, :knowledge_statements, :domains
  map.resources :big_ideas, :unifying_themes, :expectations, :expectation_stems
  map.resources :grade_span_expectations, :collection => { 
    :select_js => :post,
    :summary => :post,
    :reparse_gses => :put,
    :select => :get
  }, :member => {
    :print => :get
  }

  # not being used, but being tested
  map.resources :images
  
  # Home Controller
  map.installer '/missing_installer/:os', :controller => 'home', :action => 'missing_installer', :os => "osx"
  map.home '/readme', :controller => 'home', :action => 'readme'
  map.home '/home', :controller => 'home', :action => 'index'
  map.about '/about', :controller => 'home', :action => 'about'
  map.root :controller => 'home', :action => 'index'

  map.pick_signup '/pick_signup', :controller => 'home', :action => 'pick_signup'
  map.name_for_clipboard_data '/name_for_clipboard_data', :controller => 'home', :action =>'name_for_clipboard_data'
  # map. ':controller/:action/:id.:format'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

end

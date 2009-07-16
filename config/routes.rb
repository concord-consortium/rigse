ActionController::Routing::Routes.draw do |map|
  map.resources :biologica_chromosome_zooms
  map.resources :inner_pages, :member => {
    :destroy => :post,
    :add_page => :post,
    :add_element => :post,
    :set_page => :post,
    :sort_pages => :post, 
    :delete_page => :post
  }

  map.resources :biologica_multiple_organisms
  map.resources :biologica_breed_offsprings
  map.resources :biologica_meiosis_views
  map.resources :biologica_chromosomes
  map.resources :biologica_pedigrees
  map.resources :biologica_static_organisms
  map.resources :biologica_organisms
  map.resources :biologica_worlds

  map.resources :raw_otmls

  map.namespace(:otrunk_example) do |otrunk_example|
    otrunk_example.resources :otrunk_imports
    otrunk_example.resources :otml_categories
    otrunk_example.resources :otml_files
    otrunk_example.resources :otrunk_view_entries
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

  map.resources :n_logo_models
  map.resources :mw_modeler_pages

  map.resources :vendor_interfaces
  map.resources :probe_types
  map.resources :physical_units
  map.resources :device_configs
  map.resources :data_filters
  map.resources :calibrations

  map.resources :teacher_notes
  map.resources :author_notes

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
    :add_page => :post,
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
    :destroy => :post
  }
  
  map.resources :activities, :member => {
    :add_section => :post,
    :sort_sections => :post,
    :delete_section => :post,
    :print => :get,
    :duplicate => :get,
    :export => :get,
    :destroy => :post
  }

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

  map.resources :images
 
  # Restful Authentication Rewrites
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }
  
  map.admin '/admin', :controller =>'admin/users'
  
  # Restful Authentication Resources
  map.resources :users, :member => { 
    :preferences => [:get, :put], 
    :interface => :get,
    :suspend   => :put,
    :unsuspend => :put,
    :purge     => :delete }
    
  map.resources :passwords
  map.resource :session
  
  # Home Page
  map.home '/home', :controller => 'home', :action => 'index'
  map.root :controller => 'home', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

end

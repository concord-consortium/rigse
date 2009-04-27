ActionController::Routing::Routes.draw do |map|
  map.resources :data_tables, :member => {
    :destroy => :post
  }

  map.resources :multiple_choices, :member => {
    :destroy => :post,
    :add_answer => :post
  }

  map.resources :drawing_tools, :member => {
    :destroy => :post
  }
  
  map.resources :teacher_notes

  map.resources :vendor_interfaces

  map.resources :probe_types

  map.resources :physical_units

  map.resources :device_configs

  map.resources :data_filters

  map.resources :calibrations
  
  map.resources :xhtmls, :member => {
    :destroy => :post
  }
  
  # map.resources :xhtmls, :path_prefix => '/pages/:page_id', :name_prefix => 'page_'

  map.resources :open_responses, :member  => {
    :destroy => :post
  }
  # map.resources :open_responses, :path_prefix => '/pages/:page_id', :name_prefix => 'page_'

  map.resources :data_collectors, :member => {
    :destroy => :post
  }
  # map.resources :data_collectors, :path_prefix => '/pages/:page_id', :name_prefix => 'page_'
  
  map.resources :sections, :member => {
    :destroy => :post,
    :add_page => :post,
    :sort_pages => :post, 
    :delete_page => :post,
    :duplicate => :get
  }
    
  map.resources :pages, :member => {
    :destroy => :post,
    :add_element => :post,
    :sort_elements => :post,
    :delete_element => :post,
    :preview => :get,
    :print => :get,
    :duplicate => :get
  }

  # /pages/:id/add_element/:embeddable_type
  # /pages/:id/:embeddable_type_controller
  map.resources :pages do |page|
    page.resources :xhtmls
    page.resources :open_responses
    page.resources :data_collectors
  end
  
  map.resources :page_elements

  map.resources :investigations, :member => {
    :add_section => :post,
    :sort_sections => :post,
    :delete_section => :post,
    :duplicate => :get,
    :export => :get
  }
  map.resources :investigations do |investigation|
    investigation.resources :sections do |section|
      section.resources :pages do |page|
        page.resources :page_elements
      end
    end
  end
  

  
  map.resources :assessment_targets, :knowledge_statements, :domains
  map.resources :big_ideas, :unifying_themes, :expectations, :expectation_stems
  map.resources :grade_span_expectations, :collection => { 
    :select_js => :post,
    :reparse_gses => :put,
    :select => :get
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
  
  # Restful Authentication Resources
  map.resources :users, :member => { :preferences => [:get, :put], :interface => :get }
  map.resources :passwords
  map.resource :session
  
  # Home Page
  map.home '/home', :controller => 'home', :action => 'index'
  map.root :controller => 'home', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

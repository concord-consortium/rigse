ActionController::Routing::Routes.draw do |map|

  map.namespace(:dataservice) do |dataservice|
    dataservice.resources :bundle_loggers do |bundle_logger|
      bundle_logger.resources :bundle_contents
    end
    dataservice.resources :console_loggers do |bundle_logger|
      bundle_logger.resources :console_contents
    end
    
  end
  # 
  # dataservice.connect 'bundle_logger/:id',   :controller => 'dataservice/bundle_logger',  :action => 'update', :conditions => { :method => :post }
  # dataservice.connect 'bundle_logger/:id',   :controller => 'dataservice/bundle_logger',  :action => 'show',   :conditions => { :method => :get }
  # dataservice.connect 'bundle_logger/:id',   :controller => 'dataservice/bundle_logger',  :action => 'destroy',:conditions => { :method => :delete }    
  # dataservice.connect 'bundle_contents/:id', :controller => 'dataservice/bundle_content', :action => 'update', :conditions => { :method => :post }
  # dataservice.connect 'bundle_contents/:id', :controller => 'dataservice/bundle_content', :action => 'show',   :conditions => { :method => :get }
  # dataservice.connect 'bundle_contents/:id', :controller => 'dataservice/bundle_content', :action => 'destroy',:conditions => { :method => :delete }    

  
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

  map.resources :vendor_interfaces
  map.resources :probe_types
  map.resources :physical_units
  map.resources :device_configs
  map.resources :data_filters
  map.resources :calibrations

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

  map.namespace(:otrunk_example) do |otrunk_example|
    otrunk_example.resources :otrunk_imports
    otrunk_example.resources :otml_categories
    otrunk_example.resources :otml_files
    otrunk_example.resources :otrunk_view_entries
  end

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
    :destroy => :post,
    :list_filter => :post
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
  
  # Home Page
  map.home '/readme', :controller => 'home', :action => 'readme'
  map.home '/home', :controller => 'home', :action => 'index'
  map.about '/about', :controller => 'home', :action => 'about'
  map.root :controller => 'home', :action => 'index'

  map.pick_signup '/pick_signup', :controller => 'home', :action => 'pick_signup'

  # map. ':controller/:action/:id.:format'
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

end

ActionController::Routing::Routes.draw do |map|

  map.resources :interactive_models, :data_collectors, :multiple_choices
  map.resources :open_responses, :xhtmls

  map.resources :sections, :member => { :sort_pages => :post }
  map.resources :pages, :member => { :sort_elements => :post }
  map.resources :page_elements

  map.resources :investigations do |investigation|
    investigation.resources :sections do |section|
      section.resources :pages do |page|
        page.resources :page_elements
      end
    end
  end

  map.resources :assessment_targets, :knowledge_statements, :domains
  map.resources :big_ideas, :unifying_themes, :expectations, :expectation_stems
  map.resources :grade_span_expectations, :collection => { :reparse_gses => :put }

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
  map.resources :users
  map.resources :passwords
  map.resource :session
  
  # Home Page
  map.home '/home', :controller => 'home', :action => 'index'
  map.root :controller => 'home', :action => 'index'

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

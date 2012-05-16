RailsPortal::Application.routes.draw do
constraints :id => /\d+/ do
  namespace :saveable do
    namespace :sparks do
      resources :measuring_resistances
      resources :measuring_resistance_reports
    end
  end

  namespace :probe do
    resources :vendor_interfaces
    resources :probe_types
    resources :physical_units
    resources :device_configs
    resources :data_filters
    resources :calibrations
  end

  namespace :ri_gse do
    resources :assessment_targets
    resources :knowledge_statements
    resources :domains
    resources :big_ideas
    resources :unifying_themes
    resources :expectations
    resources :expectation_stems
    resources :grade_span_expectations do
      collection do
        get :select
        post :summary
        post :select_js
        put :reparse_gses
      end
      member do
        get :print
      end
    end
  end

  namespace :embeddable do
    namespace :smartgraph do
      resources :range_questions
    end
    namespace :biologica do
      resources :chromosome_zooms
      resources :multiple_organisms
      resources :breed_offsprings
      resources :meiosis_views
      resources :chromosomes
      resources :pedigrees
      resources :static_organisms
      resources :organisms
      resources :worlds
    end
    resources :inner_pages do
      member do
        post :sort_pages
        post :add_page
        post :add_element
      end
      match 'delete_page/:page_id', :controller => 'embeddable__inner_pages', :action => 'delete_page'
    end

    
    
    resources :lab_book_snapshots
    resources :raw_otmls
    resources :n_logo_models
    resources :mw_modeler_pages
    resources :data_tables do
      member do
        post :update_cell_data
      end
    end
    resources :multiple_choices do
      member do
        post :add_choice
      end
    end
    resources :drawing_tools
    resources :xhtmls
    resources :open_responses
    resources :data_collectors do
      member do
        put :change_probe_type
      end
    end
    resources :sound_graphers
    resources :image_questions
    resources :video_players
  end

  namespace :smartgraph do
    resources :range_questions
  end

  namespace :portal do

    resources :clazzes, :path => :classes do
      member do
        post :add_teacher
        delete :remove_teacher
        get :add_offering
        post :add_offering
        get :class_list
        get :add_student
        post :add_student
        get :remove_offering
        post :remove_offering
        get :edit_offerings
        post :edit_offerings
      end
    end

    resources :clazzes, :path => :classes do
      resources :student_clazzes
    end

    resources :courses

    resources :districts

    resources :grades

    resources :grade_levels

    resources :learners do
      member do
        get :open_response_report
        get :multiple_choice_report
        get :report
        get :bundle_report
      end
    end

    get 'offerings/:id/launch_status.:format' => 'offerings_metal#launch_status', :constraints => { :format => 'json' }

    resources :offerings do
      collection do
        get :data_test
        post :data_test
      end
      member do
        get :deactivate
        get :activate
        get :open_response_report
        post :check_learner_auth
        post :start
        get :multiple_choice_report
        get :report
        get :separated_report
        post :report_embeddable_filter
        get :learners
      end
    end

    resources :schools

    resources :school_memberships

    resources :semesters

    resources :students do
      collection do
        get :signup
        get :register
        post :register
        post :confirm
      end
    end

    resources :student_clazzes

    resources :subjects

    resources :teachers

    resources :external_user_domains

    resources :external_users

    resources :nces06_districts

    resources :nces06_schools do
      member do
        get :description
      end
    end

  end
  match '/portal/school_selector/update' => 'portal/school_selector#update'
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  match '/activate/:activation_code' => 'users#activate', :as => :activate, :activation_code => nil
  match '/forgot_password' => 'passwords#login', :as => :forgot_password
  match '/forgot_password/email' => 'passwords#email', :as => :forgot_password_email
  match '/change_password/:reset_code' => 'passwords#reset', :as => :change_password
  match '/password/:user_id/questions' => 'passwords#questions', :as => :password_questions
  match '/password/:user_id/check_questions' => 'passwords#check_questions', :as => :check_password_questions
  match '/opensession' => 'sessions#create', :as => :open_id_complete, :constraints => { :method => 'get' }
  match '/opencreate' => 'users#create', :as => :open_id_create, :constraints => { :method => 'get' }

  resources :users do
    member do
      delete :purge
      put :suspend
      put :unsuspend
      get :interface
      get :switch
      put :switch
      get :preferences
      put :preferences
      get :reset_password
    end
    resource :security_questions, :only => [:edit, :update]
  end

  match '/users/reports/account_report' => 'users#account_report', :as => :users_account_report, :method => :get
  resources :passwords
  resource :session

  resources :external_user_domains do
    resources :external_users
    resources :external_sessions
  end

  namespace :dataservice do
    resources :blobs
    resources :bundle_contents
    resources :console_contents
    resources :bundle_loggers do
      resources :bundle_contents, :except => [:create]
    end
    resources :console_loggers do
      resources :console_contents, :except => [:create]
    end
    resources :periodic_bundle_loggers, :only => [:show]
  end

  # metal routing
  post '/dataservice/bundle_loggers/:id/bundle_contents.bundle' => 'dataservice/bundle_contents_metal#create', :constraints => { :format => 'bundle' }
  post '/dataservice/console_loggers/:id/console_contents.bundle' => 'dataservice/console_contents_metal#create', :constraints => { :format => 'bundle' }
  post '/dataservice/periodic_bundle_loggers/:id/periodic_bundle_contents.bundle' => 'dataservice/periodic_bundle_contents_metal#create', :constraints => { :format => 'bundle' }, :as => 'dataservice_periodic_bundle_logger_periodic_bundle_contents'
  post '/dataservice/periodic_bundle_loggers/:id/session_end_notification.bundle' => 'dataservice/periodic_bundle_loggers_metal#session_end_notification', :constraints => { :format => 'bundle' }, :as => 'dataservice_periodic_bundle_logger_session_end_notification'

  # A prettier version of the blob w/ token url
  match 'dataservice/blobs/:id/:token.:format' => 'dataservice/blobs#show', :as => :dataservice_blob_raw_pretty, :constraints => { :token => /[a-zA-Z0-9]{32}/ }
  match 'dataservice/blobs/:id.blob/:token'    => 'dataservice/blobs#show', :as => :dataservice_blob_raw,        :constraints => { :token => /[a-zA-Z0-9]{32}/ }, :format => 'blob'

  namespace :admin do
    resources :projects do
      member do
        put :update_form
      end
    end
    resources :tags
  end

  namespace :maven_jnlp do
    resources :native_libraries
    resources :jars
    resources :properties
    resources :versioned_jnlps
    resources :versioned_jnlp_urls
    resources :icons
    resources :maven_jnlp_families
    resources :maven_jnlp_servers
  end

  namespace :otrunk_example do
    resources :otrunk_imports
    resources :otml_categories
    resources :otml_files
    resources :otrunk_view_entries
  end

  resources :teacher_notes
  resources :author_notes
  resources :lab_book_snapshots

  # resources :inner_pages do
  #   member do
  #     post :sort_pages
  #     post :delete_page
  #     post :add_page
  #     post :add_element
  #     post :set_page
  #   end
  # end

  resources :biologica_chromosome_zooms

  resources :biologica_multiple_organisms

  resources :biologica_breed_offsprings

  resources :biologica_meiosis_views

  resources :biologica_chromosomes

  resources :biologica_pedigrees

  resources :biologica_static_organisms

  resources :biologica_organisms

  resources :biologica_worlds

  resources :raw_otmls

  resources :n_logo_models

  resources :mw_modeler_pages

  resources :data_tables do
    member do
      post :update_cell_data
      get :print
    end
  end

  resources :multiple_choices do
    member do
      post :add_choice
      get :print
    end
  end

  resources :drawing_tools do
    member do
      get :print
    end
  end

  resources :xhtmls do
    member do
      get :print
    end
  end

  resources :open_responses do
    member do
      get :print
    end
  end

  resources :data_collectors do
    member do
      put :change_probe_type
      get :print
    end
  end

  resources :sections do
    collection do
      get :printable_index
    end
    member do
      post :sort_pages
      get :duplicate
      post :delete_page
      get :details_report
      post :add_page
      get :add_page
      get :usage_report
      get :print
    end
  end

  resources :pages do
    member do
      post :sort_elements
      get :duplicate
      post :delete_element
      post :paste_link
      get :preview
      post :add_element
      get :print
      post :paste
    end
  end

  match '/page/list/filter' => 'pages#index', :as => :list_filter_page, :method => :post
  resources :pages do
    resources :xhtmls
    resources :open_responses
    resources :data_collectors
  end

  resources :page_elements

  resources :investigations do
    collection do
      get :printable_index
    end
    member do
      get :duplicate
      get :details_report
      post :add_activity
      get :add_activity
      get :usage_report
      post :sort_activities
      get :print
      post :delete_activity
      get :export
    end
  end

  match '/investigations/list/preview/' => 'investigations#preview_index', :as => :investigation_preview_list, :method => :get
  match '/investigations/list/filter' => 'investigations#index', :as => :list_filter_investigation, :method => :get
  match '/investigations/teacher/:id.otml' => 'investigations#teacher', :as => :investigation_teacher_otml, :method => :get, :format => :otml
  match '/investigations/teacher/:id.dynamic_otml' => 'investigations#teacher', :as => :investigation_teacher_dynamic_otml, :method => :get, :format => :dynamic_otml
  match '/investigations/reports/usage' => 'investigations#usage_report', :as => :investigation_usage_report, :method => :get
  match '/investigations/reports/details' => 'investigations#details_report', :as => :investigation_details_report, :method => :get
  match '/report/learner' => 'report/learner#index', :as => :learner_report, :method => :get
  resources :activities do
    member do
      get :duplicate
      post :add_section
      get :add_section
      post :sort_sections
      get :print
      post :delete_section
      get :export
    end
  end

  match '/activity/list/filter' => 'activities#index', :as => :list_filter_activity, :method => :post
  resources :activities do

    resources :sections do
      resources :pages do
        resources :page_elements
      end
    end
  end

  match '/external_activities/list/preview/' => 'external_activities#preview_index', :as => :external_activity_preview_list, :method => :get
  resources :external_activities do
    member do
      get :duplicate
    end
  end

  match '/external_activity/list/filter' => 'external_activities#index', :as => :list_filter_external_activity, :method => :post

  resources :assessment_targets
  resources :knowledge_statements
  resources :domains
  resources :big_ideas
  resources :unifying_themes
  resources :expectations
  resources :expectation_stems

  resources :grade_span_expectations do
    collection do
      get :select
      post :summary
      post :select_js
      put :reparse_gses
    end
    member do
      get :print
    end
  end

  match '/resource_pages/list/filter' => 'resource_pages#index', :as => :list_filter_resource_page, :method => :post
  resources :resource_pages do
    collection do
      get :printable_index
    end
  end

  resources :attached_files
  resources :images

  if Rails.env.cucumber? || Rails.env.test?
    match '/login/:username' => 'sessions#backdoor', :as => :login_backdoor
  end

  match '/missing_installer/:os' => 'home#missing_installer', :as => :installer, :os => 'osx'
  match '/readme' => 'home#readme', :as => :readme
  match '/doc/:document' => 'home#doc', :as => :doc, :constraints => { :document => /\S+/ }
  match '/home' => 'home#index', :as => :home
  match '/about' => 'home#about', :as => :about
  match '/report' => 'home#report', :as => :report
  match '/test_exception' => 'home#test_exception', :as => :test_exception
  match '/' => 'home#index'
  match '/requirements' => 'home#requirements', :as => :requirements
  match '/stylesheets/project.css' => 'home#project_css', :as => :project_css
  match '/pick_signup' => 'home#pick_signup', :as => :pick_signup
  match '/name_for_clipboard_data' => 'home#name_for_clipboard_data', :as => :name_for_clipboard_data
  match '/banner' => 'misc#banner', :as => :banner
  post  '/installer_report' => 'misc#installer_report', :as => :installer_report
  match '/:controller(/:action(/:id))'

  root :to => 'home#index'

end
end

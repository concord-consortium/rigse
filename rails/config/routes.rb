RailsPortal::Application.routes.draw do

  devise_for :users, :controllers => {
    :registrations => 'registrations',
    :confirmations => 'confirmations',
    :omniauth_callbacks => 'authentications',
    :sessions =>  'sessions'}

  # Client stuff
  get '/auth/:provider/check' => 'misc#auth_check', as: 'auth_check'

  # Provider stuff
  match '/auth/concord_id/authorize' => 'auth#oauth_authorize', via: [:get, :post]
  match '/auth/concord_id/access_token' => 'auth#access_token', via: [:get, :post]
  match '/auth/concord_id/user' => 'auth#user', via: [:get, :post]
  match '/auth/login' => 'auth#login', :as => :auth_login, via: [:get, :post]
  match '/oauth/token' => 'auth#access_token', via: [:get, :post]
  get   '/auth/failure' => 'auth#failure'
  get   '/auth/isalive' => 'auth#isalive'
  get   '/auth/oauth_authorize' => 'auth#oauth_authorize'
  get   '/auth/user' => 'auth#user'

  match "search" => 'search#index', :as => :search, via: [:get, :post]

  get 'search/index'
  get 'search/unauthorized_user' => 'search#unauthorized_user'
  get 'search/setup_material_type' => 'search#setup_material_type'
  get '/portal/offerings/:id/activity/:activity_id' => 'portal/offerings#report', :as => :portal_offerings_report
  get '/portal/learners/:id/activity/:activity_id' => 'portal/learners#report', :as => :portal_learners_report

  get  "help" => "help#index"
  post "help/preview_help_page"
  post "home/preview_about_page"
  post "home/preview_home_page"

  # external_activities can have uuids for ids so this resource needs to lay outside the :id constaint
  resources :external_activities, path: 'eresources' do
    collection do
      post :publish
    end
    member do
      get :matedit
      get :archive
      get :unarchive
      get :set_private_before_matedit
      get :copy
      get 'collections' => 'external_activities#edit_collections'
      put 'collections' => 'external_activities#update_collections'
    end
  end

  constraints :id => /\d+/ do
    namespace :browse do
      resources :external_activities, path: 'eresources' do
        member do
          post :show
        end
      end
    end

    namespace :portal do

      get 'classes/:id/external_report/:report_id' => 'clazzes#external_report', :as => :external_class_report
      resources :clazzes, :path => :classes do
        member do
          get :add_offering
          post :add_offering
          get :class_list
          get :remove_offering
          post :remove_offering
          get :edit_offerings
          post :edit_offerings
          get :roster
          get :materials
          get :fullstatus
          get :current_clazz
        end

        resources :bookmarks, only: [:index]

        collection do
          get :info
          get 'manage', :to => 'clazzes#manage_classes'
        end
      end

      namespace :clazzes do
        post :sort_offerings
      end

      get '/bookmark/visit/:id' => 'bookmarks#visit',  :as => :visit_bookmark
      get '/bookmark/visits'    => 'bookmarks#visits', :as => :bookmark_visits

      resources :clazzes, :path => :classes do
        resources :student_clazzes
      end

      resources :courses

      resources :districts

      resources :grades

      resources :grade_levels

      resources :learners do
        member do
          get :report
          get :activity_report
          get :authorize_show
          get :current_clazz
        end
      end

      get 'offerings/:id/external_report/:report_id' => 'offerings#external_report', :as => :external_report
      resources :offerings do
        member do
          get :deactivate
          get :activate
          get :report
          post :answers
          post :offering_collapsed_status
          get :activity_report
          get :student_report
          post :student_report
        end
      end

      resources :schools

      resources :school_memberships

      resources :students do
        collection do
          get :signup
          get :register
          get :move
          post :move
          put :move
          post :move_confirm
        end
        member do
          get :ask_consent
          patch :update_consent
          get :status
          get :move
          post :move
          put :move
          post :move_confirm
        end
      end

      resources :student_clazzes

      resources :subjects

      resources :teachers

      resources :nces06_districts

      resources :nces06_schools do
        member do
          get :description
        end
      end
    end

    match '/portal/school_selector/update' => 'portal/school_selector#update', :as => :school_selector_update, via: [:get, :post]
    match '/logout' => 'sessions#destroy', :as => :logout, via: [:get, :post]
    match '/login' => 'home#index', :as => :login, via: [:get, :post]
    match '/register' => 'users#create', :as => :register, via: [:get, :post]
    match '/signup' => 'users#new', :as => :signup, via: [:get, :post]
    match '/activate/:activation_code' => 'users#activate', :as => :activate, :activation_code => nil, via: [:get, :post]
    match '/forgot_password' => 'passwords#login', :as => :forgot_password, via: [:get, :post]
    match '/forgot_password/email' => 'passwords#login', :as => :forgot_password_email, via: [:get, :post]
    match '/change_password/:reset_code' => 'passwords#reset', :as => :change_password, via: [:get, :post]
    match '/password/:user_id/questions' => 'passwords#questions', :as => :password_questions, via: [:get, :post]
    match '/password/:user_id/check_questions' => 'passwords#check_questions', :as => :check_password_questions, via: [:get, :post]
    get '/opensession' => 'sessions#create', :as => :open_id_complete, :constraints => { :method => 'get' }
    get '/opencreate' => 'users#create', :as => :open_id_create, :constraints => { :method => 'get' }
    match '/thanks_for_sign_up/:type/:login' => 'users#registration_successful', :as => :thanks_for_sign_up, :type=>nil,:login=>nil, via: [:get, :post]
    match '/portal/user_type_selector/' => 'portal/user_type_selector#index', :as => :portal_user_type_selector, via: [:get, :post]

    resources :users do
      member do
        delete :purge
        put :suspend
        put :unsuspend
        put :switch
        get :switch_back
        get :favorites
        get :preferences
        put :preferences
        get :reset_password
        get :confirm
        get :limited_edit
        patch :limited_update
      end
      resource :security_questions, :only => [:edit, :update]

      namespace :portal do
        resources :offerings, :only => [:show]
      end
    end

    get '/users/reports/account_report' => 'users#account_report', :as => :users_account_report

    resources :passwords, :only => [:update]
    post '/passwords/update_users_password' => 'passwords#update_users_password'

    namespace :dataservice do
      # 2020-09-15 NP — I doubt that we actualy need create and update
      resources :blobs, only: [:show, :index, :create, :update]
    end

    # external activity return url (:id_or_key refers learner's ID or key)
    # - key is a random UUID string, so it's impossible to guess somebody's else endpoint (more secure)
    # - we still need to support basic ID, as LARA might store this form of URLs
    post '/dataservice/external_activity_data/:id_or_key' => 'dataservice/external_activity_data#create',
         :as => 'external_activity_return'

    # Addhock protocol versioning. Sort of hacky
    post '/dataservice/external_activity_data/:id_or_key/protocol_version/:version' => 'dataservice/external_activity_data#create_by_protocol_version',
         :as => 'external_activity_versioned_return',
         :constraints => {:version => /[0-9]+/}

    # A prettier version of the blob w/ token url
    get 'dataservice/blobs/:id/:token.:format' => 'dataservice/blobs#show', :as => :dataservice_blob_raw_pretty, :constraints => { :token => /[a-zA-Z0-9]{32}/ }
    get 'dataservice/blobs/:id.blob/:token'    => 'dataservice/blobs#show', :as => :dataservice_blob_raw,        :constraints => { :token => /[a-zA-Z0-9]{32}/ }, :format => 'blob'

    namespace :admin do
      resources :settings
      resources :tags
      resources :projects do
        resources :cohorts
        resources :project_links
      end
      resources :cohorts
      resources :project_links
      resources :clients
      resources :tools
      resources :external_reports
      resources :permission_forms do
        member do
          get  :remove_form
        end
      end

      post 'permission_forms/update_forms' => 'permission_forms#update_forms', :as => :update_permissions_forms
      resources :site_notices

      get '/learner_detail/:id_or_key.:format' => 'learner_details#show',  :as => :learner_detail

      # can't use resources here as the key is a natural key instead of id and Rails 3 doesn't allow you to specifiy the param name
      get '/commons_licenses/' => 'commons_licenses#index', :as => :commons_licenses
      get '/commons_licenses/new' => 'commons_licenses#new', :as => :new_commons_license
      get '/commons_licenses/:code' => 'commons_licenses#show', :as => :commons_license
      get '/commons_licenses/:code/edit' => 'commons_licenses#edit', :as => :edit_commons_license
      post '/commons_licenses/' => 'commons_licenses#create', :as => :create_commons_license
      put '/commons_licenses/:code' => 'commons_licenses#update', :as => :update_commons_license
      delete '/commons_licenses/:code' => 'commons_licenses#destroy', :as => :delete_commons_license

      resources :authoring_sites
      resources :firebase_apps
    end

    resources :materials_collections
    resources :n_logo_models
    resources :multiple_choices do
      member do
        post :add_choice
        get :print
      end
    end

    resources :open_responses do
      member do
        get :print
      end
    end

    get '/report/learner' => 'report/learner#index', :as => :learner_report
    get '/report/learner/updated_at/:id' => 'report/learner#updated_at', :as => :learner_updated_at
    get '/report/learner/report_only' => 'report/learner#report_only', :as => :learner_report_only
    get '/report/learner/update_learners' => 'report/learner#update_learners'

    get '/report/user' => 'report/user#index', :as => :user_report

    post '/external_activities/publish/:version' => 'external_activities#publish', :as => :external_activity_publish, :version => /v\d+/
    post '/external_activities/republish/:version' => 'external_activities#republish', :as => :external_activity_republish, :version => /v\d+/

    post '/external_activity/list/filter' => 'external_activities#index', :as => :list_filter_external_activity

    resources :images
    post '/images/list/filter' => 'images#index', :as => :list_filter_image
    get '/images/:id/view'    => 'images#view',  :as => :view_image

    resources :interactives do
      collection do
        get :import_model_library
        post :import_model_library
        get :export_model_library
      end
    end

    namespace :import do
      resources :imports do
        collection do
          get :import_school_district_status
          post :import_school_district_json
          post :import_user_json
          get :import_user_status
          get :download
          get :import_activity_status
          post :import_activity
          get :import_activity_progress
          get :activity_clear_job
          post :batch_import
          get :batch_import_status
          get :failed_batch_import
          get :batch_import_data
        end
      end
      get '/imported_login/confirm_user'    => 'imported_login#confirm_user',  :as => :confirm_user_imported_login
    end

    namespace :api, :defaults => {:format => :json} do
      namespace :v1 do
        devise_for :users
        resources :countries
        resources :projects
        resources :teachers do
          collection do
            get :email_available
            get :login_available
            get :login_valid
            get :name_valid
          end
          member do
            get :get_enews_subscription
            post :update_enews_subscription
            get :get_teacher_project_views
          end
        end
        resources :students do
          collection do
            get :check_class_word
            post :join_class
            post :confirm_class_word
            post :register
            # post :add_to_class
            post :remove_from_class
          end
          member do
            post :check_password
          end
        end
        resources :security_questions
        resources :states
        resources :districts
        resources :schools
        resources :collaborations, :only => [:create] do
          collection do
            get :available_collaborators
          end
          member do
            get :collaborators_data
          end
        end
        namespace :passwords do
          post  :reset_password
        end
        namespace :materials do
          get   :own
          get   :featured
          post  :assign_to_class
          post  :unassigned_clazzes
          post  :show
          get   :all
          post  :add_favorite
          post  :remove_favorite
          get   :get_favorites
          get   :get_standard_statements
          get   :get_materials_standards
          post  :add_materials_standard
          post  :remove_materials_standard
        end
        namespace :materials_bin do
          get :collections
          get :unofficial_materials
          get :unofficial_materials_authors
        end
        namespace :search do
          get :search
          get :search_suggestions
        end

        resources :offerings, only: [:show, :update, :index] do
          member do
            # DEPRECIATED
            get :for_class
            # DEPRECIATED
            get :for_teacher
          end
        end

        resources :classes, only: [:show] do
          member do
            get :log_links
            post :set_is_archived
          end
        end
        namespace :classes do
          get :info
          get :mine
        end

        resources :teacher_classes, only: [:show] do
          collection do
            post :sort
          end
          member do
            post :copy
          end
        end

        namespace :jwt do
          post :portal
          get  :portal
          post :firebase
          get  :firebase
        end

        resources :external_activities, :only => [:create] do
          member do
            post :update_basic
          end
          collection do
            match 'update_by_url' => 'external_activities#update_by_url', :via => :post
          end
        end

        namespace :service do
          get :solr_initialized
        end

        resources :report_learners_es, only: [:index] do
          collection do
            get :external_report_query
            get :external_report_query_jwt
            post :external_report_learners_from_jwt
          end
        end

        resources :report_users, only: [:index] do
          collection do
            get :external_report_query
          end
        end

        resources :site_notices do
          member do
            delete :remove_notice
            post :dismiss_notice
          end

          collection do
            post :toggle_notice_display
          end
        end
        namespace :site_notices do
          get :edit
          get :get_notices_for_user
          get :index
          get :new
          post :create
          post :dismiss_notice
          post :edit
          post :new
          post :remove_notice
          post :toggle_notice_display
          post :update
        end

        resources :bookmarks, only: [:create, :update, :destroy] do
          collection do
            post 'sort'
          end
        end

        resources :materials_collections, :only => [] do
          member do
            post :sort_materials
            post :remove_material
          end
        end
      end
    end

    if Rails.env.cucumber? || Rails.env.test? || Rails.env.feature_test?
      get '/login/:username' => 'users#backdoor', :as => :login_backdoor
    end

    get "api/v1/materials/:material_type/:id", to: "api/v1/materials#show"

    get '/readme' => 'home#readme', :as => :readme
    get '/docs/:document' => 'home#doc', :as => :doc, :constraints => { :document => /\S+/ }
    get '/home'       => 'home#index', :as => :home
    get '/my_classes' => 'home#my_classes', :as => :my_classes
    get '/recent_activity' => 'home#recent_activity', :as => :recent_activity
    get '/getting_started' => 'home#getting_started', :as => :getting_started
    get '/about' => 'home#about'
    get '/collections' => 'home#collections'
    get '/test_exception' => 'home#test_exception', :as => :test_exception
    get '/pick_signup' => 'home#pick_signup', :as => :pick_signup
    get '/admin' => 'home#admin', :as => :admin
    get '/name_for_clipboard_data' => 'home#name_for_clipboard_data', :as => :name_for_clipboard_data
    get 'authoring' => 'home#authoring', :as => :authoring
    get '/authoring_site_redirect/:id' => 'home#authoring_site_redirect', :as => :authoring_site_redirect

    get '/time' => 'misc_metal#time', :as => :time
    get '/learner_proc_stats' => 'misc#learner_proc_stats', :as => :learner_proc_stats
    get '/learner_proc' => 'misc#learner_proc', :as => :learner_proc

    get '/misc/preflight' => 'misc#preflight', :as => :preflight
    get '/misc/stats' => 'misc#stats', :as => :stats

    get '/resources/:id(/:slug)' => 'browse/external_activities#show', :as => :stem_resources

    get '/resources/:type/:id_or_filter_value(/:slug)' => 'browse/external_activities#show', :as => :redirect_stem_resources

    get 'robots.txt'    => 'robots#index'
    get 'sitemap.xml'   => 'robots#sitemap'

    # Custom project page. This route should be always near the very bottom,
    # so the custom page URL can't overwrite another resource URL other than
    # the controller catch-all and the root route
    get '/:landing_page_slug' => 'admin/projects#landing_page', :as => :project_page, :constraints => { :landing_page_slug => /[a-z0-9\-]+/ }

    root :to => 'home#index'
  end

  # Web interface to show the delayed jobs for admins
  mount Delayed::Web::Engine, at: "/delayed_job", :constraints => lambda { |request|
    warden = request.env['warden']
    warden.user && warden.user.has_role?("admin")
  }
end

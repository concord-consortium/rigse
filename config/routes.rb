RailsPortal::Application.routes.draw do

  devise_for :users, :controllers => {
    :registrations => 'registrations',
    :confirmations => 'confirmations',
    :omniauth_callbacks => 'authentications',
    :sessions =>  'sessions'}

  # Client stuff
  match '/auth/:provider/check' => 'misc#auth_check', method: :get, as: 'auth_check'
  match '/auth/after' => 'misc#auth_after', method: :get, as: 'auth_after'

  # Provider stuff
  match '/auth/concord_id/authorize' => 'auth#oauth_authorize'
  match '/auth/concord_id/access_token' => 'auth#access_token'
  match '/auth/concord_id/user' => 'auth#user'
  match '/auth/login' => 'auth#login', :as => :auth_login
  match '/oauth/token' => 'auth#access_token'

  root :to => "home#index"

  match "search" => 'search#index', :as => :search

  get 'search/index'
  post '/search/get_current_material_unassigned_clazzes'
  post '/search/add_material_to_clazzes'
  post '/search/get_current_material_unassigned_collections'
  post '/search/add_material_to_collections'
  get 'search/unauthorized_user' => 'search#unauthorized_user'
  get 'search/get_search_suggestions'
  match '/portal/offerings/:id/activity/:activity_id' => 'portal/offerings#report', :as => :portal_offerings_report, :method => :get
  match '/portal/learners/:id/activity/:activity_id' => 'portal/learners#report', :as => :portal_learners_report, :method => :get

  post "help/preview_help_page"
  post "home/preview_home_page"

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

    namespace :browse do
      resources :investigations do
        member do
          post :show
        end
      end
      resources :activities do
        member do
          post :show
        end
      end
      resources :external_activities, path: 'eresources' do
        member do
          post :show
        end
      end
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
          get :roster
          post :add_new_student_popup
          post :copy_class
          get :materials
          get :fullstatus
        end

        resources :bookmarks, only: [:index] do
          collection do
            post 'add'
            post 'add_padlet'
          end
        end

        collection do
          get :info
          #get :manage_classes, :path => 'manage'
          match 'manage', :to => 'clazzes#manage_classes'
          #post :manage_classes_save, :as => 'manage_save'
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
          get :activity_report
        end
      end

      get 'offerings/:id/launch_status.:format' => 'offerings_metal#launch_status', :constraints => { :format => 'json' }, :as => :launch_status
      get 'offerings/:id/external_report/:report_id' => 'offerings#external_report', :as => :external_report
      resources :offerings do
        member do
          get :deactivate
          get :activate
          get :open_response_report
          get :multiple_choice_report
          get :report
          get :separated_report
          post :report_embeddable_filter
          post :answers
          post :offering_collapsed_status
          post :get_recent_student_report
          get :activity_report
          get :student_report
          post :student_report
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
        member do
          get :ask_consent
          put :update_consent
          get :status
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

      # TODO: clean up these adhoc bookmark routes:
      match '/bookmark/visit/:id'      => 'bookmarks#visit',      :as => :visit_bookmark
      match '/bookmark/delete/:id'     => 'bookmarks#delete',     :as => :delete_bookmark
      match '/bookmark/visits'         => 'bookmarks#visits',     :as => :bookmark_visits
      match '/bookmark/sort'           => 'bookmarks#sort',       :method => :post, :as => :sort_bookmarks
      match '/bookmark/edit'           => 'bookmarks#edit',       :method => :post, :as => :edit_bookmark
    end

    match '/portal/school_selector/update' => 'portal/school_selector#update', :as => :school_selector_update
    match '/logout' => 'sessions#destroy', :as => :logout
    match '/login' => 'home#index', :as => :login
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
    match '/thanks_for_sign_up/:type/:login' => 'users#registration_successful', :as => :thanks_for_sign_up, :type=>nil,:login=>nil
    match '/portal/user_type_selector/' => 'portal/user_type_selector#index', :as => :portal_user_type_selector

    resources :users do
      member do
        delete :purge
        put :suspend
        put :unsuspend
        get :interface
        put :switch
        get :favorites
        get :preferences
        put :preferences
        get :reset_password
        get :confirm
        get :limited_edit
        put :limited_update
      end
      resource :security_questions, :only => [:edit, :update]

      # this is added to prevent caching and reuse of jnlp files by other users
      # this caching or saving of jnlps could still happen, but adding this eliminates
      # one potential way it could be cached and reused
      namespace :portal do
        resources :offerings, :only => [:show]
      end
    end

    match '/users/reports/account_report' => 'users#account_report', :as => :users_account_report, :method => :get
    resources :passwords
    #resource :session

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
      resources :bucket_loggers, :only => [:show]
    end

    # metal routing
    post '/dataservice/bundle_loggers/:id/bundle_contents.bundle' => 'dataservice/bundle_contents_metal#create', :constraints => { :format => 'bundle' }
    post '/dataservice/console_loggers/:id/console_contents.bundle' => 'dataservice/console_contents_metal#create', :constraints => { :format => 'bundle' }
    post '/dataservice/periodic_bundle_loggers/:id/periodic_bundle_contents.bundle' => 'dataservice/periodic_bundle_contents_metal#create', :constraints => { :format => 'bundle' }, :as => 'dataservice_periodic_bundle_logger_periodic_bundle_contents'
    post '/dataservice/periodic_bundle_loggers/:id/session_end_notification.bundle' => 'dataservice/periodic_bundle_loggers_metal#session_end_notification', :constraints => { :format => 'bundle' }, :as => 'dataservice_periodic_bundle_logger_session_end_notification'

    # bucket contents routes
    post '/dataservice/bucket_loggers/learner/:id/bucket_contents(.:format)' => 'dataservice/bucket_contents_metal#create_by_learner', :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_contents_by_learner'
    get  '/dataservice/bucket_loggers/learner/:id/bucket_contents(.:format)' => 'dataservice/bucket_loggers#show_by_learner',   :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_loggers_by_learner'
    post '/dataservice/bucket_loggers/name/:name/bucket_contents(.:format)' => 'dataservice/bucket_contents_metal#create_by_name', :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_contents_by_name'
    get  '/dataservice/bucket_loggers/name/:name/bucket_contents(.:format)' => 'dataservice/bucket_loggers#show_by_name',   :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_loggers_by_name'
    post '/dataservice/bucket_loggers/:id/bucket_contents(.:format)' => 'dataservice/bucket_contents_metal#create', :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_contents'

    # bucket log items routes
    post '/dataservice/bucket_loggers/:id/bucket_log_items(.:format)'         => 'dataservice/bucket_log_items_metal#create',            :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_log_items'
    post '/dataservice/bucket_loggers/learner/:id/bucket_log_items(.:format)' => 'dataservice/bucket_log_items_metal#create_by_learner', :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_log_items_by_learner'
    get  '/dataservice/bucket_loggers/learner/:id/bucket_log_items(.:format)' => 'dataservice/bucket_loggers#show_log_items_by_learner', :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_loggers_log_items_by_learner'
    post '/dataservice/bucket_loggers/name/:name/bucket_log_items(.:format)' => 'dataservice/bucket_log_items_metal#create_by_name',     :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_log_items_by_name'
    get  '/dataservice/bucket_loggers/name/:name/bucket_log_items(.:format)' => 'dataservice/bucket_loggers#show_log_items_by_name',     :constraints => { :format => 'bundle' }, :as => 'dataservice_bucket_loggers_log_items_by_name'

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
    match 'dataservice/blobs/:id/:token.:format' => 'dataservice/blobs#show', :as => :dataservice_blob_raw_pretty, :constraints => { :token => /[a-zA-Z0-9]{32}/ }
    match 'dataservice/blobs/:id.blob/:token'    => 'dataservice/blobs#show', :as => :dataservice_blob_raw,        :constraints => { :token => /[a-zA-Z0-9]{32}/ }, :format => 'blob'

    namespace :admin do
      resources :settings
      resources :tags
      resources :projects
      resources :clients
      resources :external_reports
      resources :permission_forms do
        member do
          post :update_forms
          get  :remove_form
        end
      end
      resources :site_notices do
        member do
          delete :remove_notice
          post :dismiss_notice
        end

        collection do
          #get :manage_classes, :path => 'manage'
          post :toggle_notice_display
          #post :manage_classes_save, :as => 'manage_save'
        end
      end
      get '/learner_detail/:id_or_key.:format' => 'learner_details#show',  :as => :learner_detail

      # can't use resources here as the key is a natural key instead of id and Rails 3 doesn't allow you to specifiy the param name
      get '/commons_licenses/' => 'commons_licenses#index', :as => :commons_licenses
      get '/commons_licenses/new' => 'commons_licenses#new', :as => :new_commons_license
      get '/commons_licenses/:code' => 'commons_licenses#show', :as => :commons_license
      get '/commons_licenses/:code/edit' => 'commons_licenses#edit', :as => :edit_commons_license
      post '/commons_licenses/' => 'commons_licenses#create', :as => :create_commons_license
      put '/commons_licenses/:code' => 'commons_licenses#update', :as => :update_commons_license
      delete '/commons_licenses/:code' => 'commons_licenses#destroy', :as => :delete_commons_license
    end

    resources :materials_collections do
      member do
        post :sort_materials
        post :remove_material
      end
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
        post :add_page
        get :add_page
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
        post :add_activity
        get :add_activity
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
    match '/report/learner' => 'report/learner#index', :as => :learner_report, :method => :get
    match '/report/learner/logs_query' => 'report/learner#logs_query', :as => :learner_logs_query, :method => :get
    match '/report/learner/updated_at/:id' => 'report/learner#updated_at', :as => :learner_updated_at, :method => :get
    match '/report/learner/report_only' => 'report/learner#report_only', :as => :learner_report_only, :method => :get
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
    match '/external_activities/publish/:version' => 'external_activities#publish', :as => :external_activity_publish, :method => :post, :version => /v\d+/
    match '/external_activities/republish/:version' => 'external_activities#republish', :as => :external_activity_republish, :method => :post, :version => /v\d+/
    resources :external_activities, path: 'eresources' do
      collection do
        post :publish
      end
      member do
        get :duplicate
        get :matedit
        get :archive
        get :unarchive
        get :set_private_before_matedit
        get :copy
        get :edit_basic
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

    resources :images
    match '/images/list/filter' => 'images#index', :as => :list_filter_image, :method => :post
    match '/images/:id/view'    => 'images#view',  :as => :view_image, :method => :get

    resources :installer_reports

    resources :images

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
      match '/imported_login/confirm_user'    => 'imported_login#confirm_user',  :as => :confirm_user_imported_login, :method => :get
    end

    namespace :api, :defaults => {:format => :json} do
      namespace :v1 do
        resources :countries
        resources :projects
        resources :teachers do
          collection do
            get :email_available
            get :login_available
            get :login_valid
            get :name_valid
          end
        end
        resources :students do
          collection do
            get :check_class_word
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
        namespace :materials do
          get   :own
          get   :featured
          post  :assign_to_class
          get   :all
          get   :add_favorite
          get   :remove_favorite
          get   :get_favorites
        end
        namespace :materials_bin do
          get :collections
          get :unofficial_materials
          get :unofficial_materials_authors
        end
        namespace :search do
          get :search
        end
        namespace :answers do
          get :student_answers
        end
        resources :reports, only: [:show, :update]

        resources :offerings, only: [:show] do
          member do
            get :for_class
            get :for_teacher
          end
        end

        resources :classes, only: [:show] do
          member do
            get :log_links
          end
        end
        namespace :classes do
          get :info
        end

        namespace :jwt do
          post :firebase
        end

        #
        # Service APIs
        #
        namespace :service do
          get :sunspot_reindex
        end

      end
    end

    if Rails.env.cucumber? || Rails.env.test?
      match '/login/:username' => 'users#backdoor', :as => :login_backdoor
    end

    match "api/v1/materials/:material_type/:id", to: "api/v1/materials#show"

    match '/missing_installer/:os' => 'home#missing_installer', :as => :installer, :os => 'osx'
    match '/readme' => 'home#readme', :as => :readme
    match '/docs/:document' => 'home#doc', :as => :doc, :constraints => { :document => /\S+/ }
    match '/home'       => 'home#index', :as => :home
    match '/my_classes' => 'home#my_classes', :as => :my_classes
    match '/recent_activity' => 'home#recent_activity', :as => :recent_activity
    match '/getting_started' => 'home#getting_started', :as => :getting_started
    match '/about' => 'home#about', :as => :about
    match '/report' => 'home#report', :as => :report
    match '/test_exception' => 'home#test_exception', :as => :test_exception
    match '/' => 'home#index', :as => :root
    match '/requirements' => 'home#requirements', :as => :requirements
    match '/stylesheets/settings.css' => 'home#settings_css', :as => :settings_css
    match '/pick_signup' => 'home#pick_signup', :as => :pick_signup
    match '/admin' => 'home#admin', :as => :admin
    match '/name_for_clipboard_data' => 'home#name_for_clipboard_data', :as => :name_for_clipboard_data
    match 'authoring' => 'home#authoring', :as => :authoring

    match '/banner' => 'misc#banner', :as => :banner
    match '/time' => 'misc_metal#time', :as => :time
    match '/learner_proc_stats' => 'misc#learner_proc_stats', :as => :learner_proc_stats
    match '/learner_proc' => 'misc#learner_proc', :as => :learner_proc
    post  '/installer_report' => 'misc#installer_report', :as => :installer_report

    match '/stem-resources/:type/:id(/:slug)' => 'home#stem_resources', :as => :stem_resources

    match '/:controller(/:action(/:id))'

    root :to => 'home#index'
  end
  # Web interface to show the delayed jobs for admins
  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post], :constraints => lambda { |request|
    warden = request.env['warden']
    warden.user && warden.user.has_role?("admin")
  }

  # Custom project page. This route should be always at the very bottom,
  # so the custom page URL can't overwrite another resource URL!
  get '/:landing_page_slug' => 'admin/projects#landing_page', :as => :project_page, :constraints => { :landing_page_slug => /[a-z0-9\-]+/ }
end

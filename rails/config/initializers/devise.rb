require Rails.root.join("lib/bearer_token_authenticatable").to_s
require Rails.root.join("lib/jwt_bearer_token_authenticatable").to_s

# loads OmniAuth::Strategies::Schoology for omniauth configuration
require File.expand_path("../../../lib/omni_auth/strategies/schoology", __FILE__)

# loads OmniAuth::Strategies::PortalGoogle for omniauth configuration
require File.expand_path("../../../lib/omni_auth/strategies/portal_google", __FILE__)

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.secret_key = ENV.fetch('DEVISE_SECRET_KEY', '71120fd5d876abea0bd88b933416dac4423afc9a5f7ccd591fe4b5d7bf32752b376c51a6cdb8dcba30be125ca75e59679a41b19804516313ccf4c813d74f37bb')
  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class with default "from" parameter.
  config.mailer_sender = "admin@concord.org"

  # Configure the class responsible to send e-mails.
  config.mailer = "UserMailer"

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
   config.authentication_keys = [ :login ]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [ :email ]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [ :email ]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Basic Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:token]` will
  # enable it only for token authentication.
  # config.http_authenticatable = false

  # If http headers should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. "Application" by default.
  # config.http_authentication_realm = "Application"

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # :http_auth and :token_auth by adding those symbols to the array below.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing :skip => :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments.
  config.stretches = (Rails.env.development? || Rails.env.production? || Rails.env.staging?) ? 10 : 1
  #config.stretches = 10

  # Setup a pepper to generate the encrypted password.
  # config.pepper = "c035da42b7b4b6cf6b985bebab88a20d78f62c6593f818992be75dca07cf7f6ad9bf983ee8b71ed56354487055fb8ffba683dca86b80f31072ca8692f55dfbc1"

  # In order to run the user specs the encrypted passwords
  # for the 'quentin' and 'aaron' users in spec/fixtures/users.yml
  # need to be created with a hard-coded pepper used during testing.
  config.pepper = (Rails.env.development? || Rails.env.production? || Rails.env.staging?) ? APP_CONFIG[:pepper] : 'sitekeyforrunningtests'

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming his account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming his account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming his account.
  # config.allow_unconfirmed_access_for = 2.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed new email is stored in
  # unconfirmed email column, and copied to email column on successful confirmation.
  config.reconfirmable = false

  # Defines which key will be used when confirming an account
  config.confirmation_keys = [ :email ]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # :secure => true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length. Default is 6..128.
  # config.password_length = 6..128

  # Email regex used to validate email formats. It simply asserts that
  # an one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # RAILS 5: needed to set to remove deprecation warning.  This is the current behavior according to the warning.
  config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = 90.minutes

  # If true, expires auth token on session timeout.
  # config.expire_auth_token_on_timeout = false

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [ :email ]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [ :email ]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper)
  # config.encryptor = :sha512

  # ==> Configuration for :token_authenticatable
  # Defines name of the authentication token params key
  # config.token_authentication_key = :auth_token

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ["*/*", :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :get

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'
  if ENV['SCHOOLOGY_CONSUMER_KEY'].present? && ENV['SCHOOLOGY_CONSUMER_SECRET'].present?
    SETUP_PROC = lambda do |env|
      host = env['rack.session'][:schoology_host]
      if host
        env['omniauth.strategy'].options[:client_options][:authorize_url] = "https://#{host}/oauth/authorize"
      end
    end
    config.omniauth 'schoology', ENV['SCHOOLOGY_CONSUMER_KEY'], ENV['SCHOOLOGY_CONSUMER_SECRET'],
      {
        strategy_class: OmniAuth::Strategies::Schoology,
        scope: 'user',
        setup: SETUP_PROC
      }
  end


  if ENV['GOOGLE_CLIENT_KEY'].present? && ENV['GOOGLE_CLIENT_SECRET'].present?

    config.omniauth 'google', ENV['GOOGLE_CLIENT_KEY'], ENV['GOOGLE_CLIENT_SECRET'],
      {
        name: 'google',
        strategy_class: OmniAuth::Strategies::PortalGoogle,
        scope: [ 'https://www.googleapis.com/auth/userinfo.profile',
                 'https://www.googleapis.com/auth/userinfo.email'    ]
      }

  end

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(:scope => :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: "/my_engine"
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine

  # When using omniauth, Devise cannot automatically set Omniauth path,
  # so you need to do it manually. For the users scope, it would be:
  config.omniauth_path_prefix = "/users/auth"

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
end

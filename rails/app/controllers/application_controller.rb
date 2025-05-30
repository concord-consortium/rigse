require 'haml'
require 'will_paginate/array'

BrowserSpecificiation = Struct.new(:browser, :version)

class PunditUserContext
  attr_reader :user, :original_user, :request, :params

  def initialize(user, original_user, request, params)
    @user = user
    @original_user = original_user
    @request = request
    @params = params
  end
end

class ApplicationController < ActionController::Base
  include Clipboard
  include Pundit::Authorization

  protect_from_forgery prepend: false

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  def pundit_user
    PunditUserContext.new(current_user, @original_user, request, params)
  end

  # With +respond_to do |format|+, "406 Not Acceptable" is sent on invalid format.
  # With a regular render (implicit or explicit), ActionView::MissingTemplate
  # exception is raised instead. The MissingTemplate exception triggers an
  # exception notification that we don't really care about.
  # So instead we catch that and raise a RoutingError which Rails turns
  # into a 404 response.
  rescue_from(ActionView::MissingTemplate) do |e|
    request.format = :html
    raise ActionController::RoutingError.new('Not Found')
  end

  layout 'application'
  def test
    render :html => mce_in_place_tag(Page.create,'description','none')
  end


  # helper :all # include all helpers, all the time
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_action :setup_container
  before_action :reject_old_browsers

  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time

  before_action :original_user
  before_action :portal_resources
  before_action :check_for_select_portal_user_type
  before_action :check_for_password_reset_requirement
  before_action :check_student_security_questions_ok
  before_action :check_student_consent
  before_action :set_locale
  before_action :wide_layout_for_anonymous

  # Portal::School.find(:first).members.count

  protected

  def pundit_user_not_authorized(exception)
    # without the no-store Chrome will cache this redirect in some cases
    # for example if a student tries to access a collection page, and then they
    # log out and try to access it again. In this case Chrome sends them to the
    # cached location of "/my-classes". By default rails adds 'no-cache' but that isn't
    # strong enough.
    response.headers['Cache-Control'] = 'no-store'

    error_message = not_authorized_error_message
    if request.xhr?
      render :html => "<div class='flash_error'>#{error_message}</div>", :status => 403
    else
      if current_user
        if BoolEnv['RESEARCHER_REPORT_ONLY']
          # if we are here then current user is not authorized to access the reports.
          # The normal code path would send them in a redirect loop
          # instead sign them out and show them a page telling them this ia report only portal
          sign_out :user
          redirect_to learner_report_only_path
        else
          # only show the error alert if we are not redirecting after signing in
          # An error on redirecting after signing in should only happen in two cases:
          # 1. the user was logged out and then clicked on an restricted link, then the user
          #    didn't actually log in, but just left the page there. Then a different user
          #    logged in. This new user didn't have access to the page of the original user
          #    so this exception was thrown during the automatic redirect to the original
          # 2. A anonymous user tried to access something they shouldn't access. They should
          #    have been shown a message and directed to the login page.  Now if the user
          #    logs in the portal will redirect to this initial page. Since the user already
          #    saw the message there is no need to show it again.
          # So instead of showing the error message again, we just send the user to the
          # default login page for that user.
          flash['alert'] = error_message if not params[:redirecting_after_sign_in]

          redirect_to view_context.current_user_home_path
        end
      else
        flash['alert'] = error_message
        # send the anonymous user to the login page, and then try to send the user back
        # to the original page. In the case of a post request this won't always work so
        # well. It will redirect the user to the GET route of the same URL that was posted
        # to. Often this is the index page of the resource.
        redirect_to auth_login_path(after_sign_in_path: request.path)
      end
    end
  end

  def setup_container
    @container_type = self.class.name[/(.+)sController/,1]
    @container_id =  request.path_parameters.symbolize_keys[:id]
  end

  def current_settings
    @_settings ||= Admin::Settings.default_settings
  end

  def configured_search_path
    if current_settings && current_settings.custom_search_path.present?
      current_settings.custom_search_path
    else
      search_path # config/routes.rb
    end
  end
  # Make this method available as a helper method too (in templates).
  helper_method :configured_search_path

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(::Rails.root.to_s, 'public', '404.html'), :formats => [:html], :status => 404
  end


  def param_find(token_sym, force_nil=false)
    token = token_sym.to_s
    result = nil
    eval_string = <<-EOF
      if params[:#{token}]
        result = session[:#{token}] = cookies[:#{token}] = params[:#{token}]
      elsif force_nil
         session[:#{token}] = cookies[:#{token}] = nil
      else
        result = session[:#{token}] || cookies[:#{token}]
      end
    EOF
    eval eval_string
    result = nil if result == ""
    result
  end


  def get_scope(default)
    begin
      @scope = default
      if container_type = params[:scope_type]
        @scope = container_type.constantize.find(params[:scope_id])
      elsif (container_type = params[:container_type]) && params[:container_id]
        @scope = container_type.constantize.find(params[:container_id])
      end
      @scope
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def valid_uuid(value)
    value.is_a?(String) && value.length == 36
  end

  def humanized_action(map={})
    key = action_name.to_sym
    if map.key?(key)
      name = map[key]
    else
      name = case action_name
      when "index" then "list"
      when "new", "duplicate" then "create"
      when "show" then "view"
      else action_name
      end
    end
    name.humanize
  end

  def not_authorized_error_message(options={})
    resource_type = options[:resource_type] || ''
    resource_name = options[:resource_name] || ''
    additional_info = options[:additional_info] || ''

    is_singular = action_name != "index"

    action = humanized_action.downcase
    # More user-friendly error message
    if current_user.nil?
      error_message = "You need to sign in to #{action} this #{resource_type.empty? ? 'resource' : resource_type}"
    else
      error_message = "You don't have permission to #{action} this #{resource_type.empty? ? 'resource' : resource_type}"
    end

    # Add resource name if available
    error_message = "#{error_message}#{resource_name.empty? ? '' : " (#{resource_name})"}"

    # Add additional info if available
    error_message = "#{error_message}. #{additional_info}" if !additional_info.empty?

    error_message
  end

  private

  # setup the portal_teacher and student instance variables
  def portal_resources
    @portal_teacher = current_visitor.portal_teacher
    @portal_student = current_visitor.portal_student
  end

  # Accesses the user that this session originally logged in as.
  def original_user
    if session[:original_user_id]
      @original_user ||=  User.find(session[:original_user_id])
    else
      @original_user = current_visitor
    end
  end

  def redirect_back_or(path)
    redirect_back(fallback_location: path)
  end

  def session_sensitive_path
    path = request.env['PATH_INFO']
    return path =~ /password|session|sign_in|sign_out|security_questions|consent|help|user_type_selector/i
  end

  def check_for_select_portal_user_type
    if request.format && request.format.html? && current_visitor && current_visitor.require_portal_user_type && !current_visitor.has_portal_user_type?
      unless session_sensitive_path
        flash.keep

        #
        # TODO If there were some way render the underlying content of
        # the omniauth_origin url beneath the modal signup popup, that would
        # be nice.
        #
        # Also if this could be passed in, rather than stored in the
        # session, that would.
        #
        # Otherwise, this is not actually used.
        #
        redirect_to portal_user_type_selector_path(omniauth_origin: session["omniauth.origin"])

      end
    end
  end

  def check_for_password_reset_requirement
    if request.format && request.format.html? && current_visitor && current_visitor.require_password_reset
      unless session_sensitive_path
        flash.keep
        redirect_to change_password_path :reset_code => "0"
      end
    end
  end

  def check_student_security_questions_ok
    if request.format && request.format.html? && current_settings && current_settings.use_student_security_questions && !current_visitor.portal_student.nil? && current_visitor.security_questions.size < 3
      unless session_sensitive_path
        flash.keep
        redirect_to(edit_user_security_questions_path(current_visitor))
      end
    end
  end

  def check_student_consent
    if request.format && request.format.html? && current_settings && current_settings.require_user_consent? && !current_visitor.portal_student.nil? && !current_visitor.asked_age?
      unless session_sensitive_path
        flash.keep
        redirect_to(ask_consent_portal_student_path(current_visitor.portal_student))
      end
    end
  end

  # this is normally called by devise during the sessions#create action
  # so it has access to the parameters that were passed in. This allows us to pass
  # a hidden param :after_sign_in_path to the sign in form.
  def after_sign_in_path_for(resource)
    redirect_path = view_context.current_user_home_path

    if params[:after_sign_in_path].present?
      # the check for to see if the user has permission to view the after_sigin_in_path
      # page is handled by the controller of this new page.
      # if the user doesn't have permission to see the new page they will be sent to their
      # home page. They will also not see a error message because of the
      # redirecting_after_sign_in parameter that is added here.
      # See pundit_user_not_authorized for the implementation

      redirect_uri = URI.parse(params[:after_sign_in_path])

      # Only allow redirecting to paths. If the redirect url has a host do not redirect
      # this prevents an open redirect. More info about open redirects are here:
      # https://cwe.mitre.org/data/definitions/601.html
      if redirect_uri.host.nil?
        query = Rack::Utils.parse_query(redirect_uri.query)
        # add an extra param to this path, so we don't go in a loop, see pundit_user_not_authorized
        query["redirecting_after_sign_in"] = '1'
        redirect_uri.query = Rack::Utils.build_query(query)
        redirect_path = redirect_uri.to_s
      end
    end

    redirect_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def set_locale
    # Set locale according to theme
    name = ENV['THEME'].blank? ? "en" : "en-#{ENV['THEME'].upcase}"
    if I18n.available_locales.include?(name.to_sym)
      I18n.locale = name.to_sym
    end
  end

  def wide_layout_for_anonymous
    @wide_content_layout = true if current_visitor.anonymous?
  end

  def reject_old_browsers
    user_agent = UserAgent.parse(request.user_agent)
    min_browser = BrowserSpecificiation.new("Internet Explorer", "9.0")
    if user_agent < min_browser
      @wide_content_layout = true
      @user_agent = user_agent
      render 'home/bad_browser', :layout => "old_browser"
    end
  end

  private

  def get_theme
    ENV['THEME'].blank? ? 'learn' : ENV['THEME']
  end

end

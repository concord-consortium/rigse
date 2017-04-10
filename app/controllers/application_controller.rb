require 'themes_for_rails'
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
  include Pundit

  protect_from_forgery

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  def pundit_user_not_authorized(exception)
    error_message = not_authorized_error_message
    if request.xhr?
      render :text => "<div class='flash_error'>#{error_message}</div>", :status => 403
    else
      if current_user
        if ENV['RESEARCHER_REPORT_ONLY']
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
          flash[:alert] = error_message if not params[:redirecting_after_sign_in]
          redirect_to after_sign_in_path_for(current_user)
        end
      else
        flash[:alert] = error_message
        # send the anonymous user to the login page, and then try to send the user back
        # to the original page. In the case of a post request this won't always work so
        # well. It will redirect the user to the GET route of the same URL that was posted
        # to. Often this is the index page of the resource.
        redirect_to auth_login_path(after_sign_in_path: request.path)
      end
    end
  end

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

  theme :get_theme

  def test
    render :text => mce_in_place_tag(Page.create,'description','none')
  end

  def self.set_theme(name)
    @@theme = name
  end

  def get_theme
    @@theme ||= ( APP_CONFIG[:theme] || 'default' )
  end

  def self.get_theme
    @@theme ||= ( APP_CONFIG[:theme] || 'default' )
  end

  # helper :all # include all helpers, all the time
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_filter :setup_container
  before_filter :reject_old_browsers

  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time

  before_filter :original_user
  before_filter :portal_resources
  before_filter :check_for_select_portal_user_type
  before_filter :check_for_password_reset_requirement
  before_filter :check_student_security_questions_ok
  before_filter :check_student_consent
  before_filter :set_locale
  before_filter :wide_layout_for_anonymous

  # Portal::School.find(:first).members.count

  protected

  def setup_container
    @container_type = self.class.name[/(.+)sController/,1]
    @container_id =  request.symbolized_path_parameters[:id]
  end

  def current_settings
    @_settings ||= Admin::Settings.default_settings
  end

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(::Rails.root.to_s, 'public', '404'), :formats => [:html], :status => 404
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
    error_message = "#{current_user.nil? ? "Anonymous users" : "You (#{current_visitor.login})"} can not #{action} the requested"
    error_message = "#{error_message} #{resource_name.empty? ? '' : "'#{resource_name}' "}#{resource_type.empty? ? 'resource' : resource_type.pluralize(is_singular ? 1 : 2 )}"
    error_message = "#{error_message}, #{additional_info}" if !additional_info.empty?
    error_message = "#{error_message}.  Please sign in to #{action} #{is_singular ? 'it' : 'them'}." if current_user.nil?

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
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to path
  end

  def session_sensitive_path
    path = request.env['PATH_INFO']
    return path =~ /password|session|sign_in|sign_out|security_questions|consent|help|user_type_selector/i
  end

  def check_for_select_portal_user_type
    if request.format && request.format.html? && current_visitor && current_visitor.require_portal_user_type && !current_visitor.has_portal_user_type?
      unless session_sensitive_path
        flash.keep
        redirect_to portal_user_type_selector_path
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
    redirect_path = root_path
    if ENV['RESEARCHER_REPORT_ONLY']
      redirect_path = learner_report_path
    elsif current_user.portal_student
      redirect_path = my_classes_path
    elsif params[:after_sign_in_path]
      # add an extra param to this path we don't go in a loop, see pundit_user_not_authorized
      redirect_uri = URI.parse(params[:after_sign_in_path])
      query = Rack::Utils.parse_query(redirect_uri.query)
      query["redirecting_after_sign_in"] = '1'
      redirect_uri.query = Rack::Utils.build_query(query)
      redirect_path = redirect_uri.to_s
    elsif APP_CONFIG[:recent_activity_on_login] && current_user.portal_teacher
      if current_user.has_active_classes?
        # Teachers with active classes are redirected to the "Recent Activity" page
        redirect_path = recent_activity_path
      else
        redirect_path = getting_started_path
      end
    end
    if session[:sso_callback_params]
      AccessGrant.prune!
      access_grant = current_user.access_grants.create({:client => session[:sso_application], :state => session[:sso_callback_params][:state]}, :without_protection => true)
      sso_redirect = access_grant.redirect_uri_for(session[:sso_callback_params][:redirect_uri])
      # the user has been logged in by another auth provider via a popup window:
      # AutomaticallyClosingPopupLink in that case the other auth provider redirects in the
      # the window, so the auth_redirect session var is set which is then picked up by the
      # misc#auth_after action.
      if session[:auth_popup]
        session[:auth_popup] = nil
        session[:auth_redirect] = sso_redirect
      else
        redirect_path = sso_redirect
      end
      session[:sso_callback_params] = nil
      session[:sso_application] = nil
    end
    return redirect_path
  end

  def after_sign_out_path_for(resource)
    redirect_url = "#{params[:redirect_uri]}?re_login=true&provider=#{params[:provider]}"
    if params[:re_login]
      session[:sso_callback_params] = nil
      session[:sso_application] = nil
      redirect_url
    else
      root_path
    end
  end

  def set_locale
    # Set locale according to theme
    name = "en-#{APP_CONFIG[:theme].upcase}" || "en"
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

end

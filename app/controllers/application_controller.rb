require 'themes_for_rails'
require 'haml'
require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include Clipboard

  # protect_from_forgery
  self.allow_forgery_protection = false

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

  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time

  before_filter :original_user
  before_filter :portal_resources
  before_filter :check_for_password_reset_requirement
  before_filter :check_student_security_questions_ok
  before_filter :check_student_consent

  # Portal::School.find(:first).members.count

  protected


  def setup_container
    @container_type = self.class.name[/(.+)sController/,1]
    @container_id =  request.symbolized_path_parameters[:id]
  end

  def current_project
    @_project ||= Admin::Project.default_project
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
    return path =~ /password|session|sign_in|sign_out|security_questions|consent|help/i
  end

  def check_for_password_reset_requirement
    if current_visitor && current_visitor.require_password_reset
      unless session_sensitive_path
        flash.keep
        redirect_to change_password_path :reset_code => "0"
      end
    end
  end

  def check_student_security_questions_ok
    if current_project && current_project.use_student_security_questions && !current_visitor.portal_student.nil? && current_visitor.security_questions.size < 3
      unless session_sensitive_path
        flash.keep
        redirect_to(edit_user_security_questions_path(current_visitor))
      end
    end
  end

  def check_student_consent
    if current_project && current_project.require_user_consent? && !current_visitor.portal_student.nil? && !current_visitor.asked_age?
      unless session_sensitive_path
        flash.keep
        redirect_to(ask_consent_portal_student_path(current_visitor.portal_student))
      end
    end
  end

  def after_sign_in_path_for(resource)
    cookies[:current_user_single_sign_on_id] = {
     :value => current_user.id,
     :domain => '.rites.concord.zeuslearning.com'
    }
    redirect_path = root_path
    if APP_CONFIG[:recent_activity_on_login] && current_visitor.portal_teacher
      portal_teacher = current_visitor.portal_teacher
      if (portal_teacher.teacher_clazzes.select{|tc| tc.active }).count > 0
        # Teachers with active classes are redirected to the "Recent Activity" page
        redirect_path = recent_activity_path
      end
    end
    if session[:sso_callback_params]
      AccessGrant.prune!
      access_grant = current_user.access_grants.create({:client => session[:sso_application], :state => session[:sso_callback_params][:state]}, :without_protection => true)
      redirect_path = access_grant.redirect_uri_for(session[:sso_callback_params][:redirect_uri])
      session[:sso_callback_params] = nil
      session[:sso_application] = nil
    end
    return redirect_path
  end

end

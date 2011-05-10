class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include Clipboard
  include ContainerController
  
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
  filter_parameter_logging :password, :password_confirmation

  before_filter :check_user
  before_filter :original_user
  before_filter :portal_resources

  # Portal::School.find(:first).members.count

  protected


  def setup_container
    @container_type = self.class.name[/(.+)Controller/,1]
    @container_type = @container_type.singularize if @container_type
    @container_id =  request.symbolized_path_parameters[:id]
  end

  def current_project
    @_project ||= Admin::Project.default_project
  end

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
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

  private

  # setup the portal_teacher and student instance variables
  def portal_resources
    @portal_teacher = current_user.portal_teacher
    @portal_student = current_user.portal_student
  end

  # Accesses the user that this session originally logged in as.
  def original_user
    if session[:original_user_id]
      @original_user ||=  User.find(session[:original_user_id])
    else
      @original_user = current_user
    end
  end


  def check_user
    if logged_in?
      self.current_user = current_user
    else
      self.current_user = User.anonymous
    end
  end


  def redirect_back_or(path)
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to path
  end

end

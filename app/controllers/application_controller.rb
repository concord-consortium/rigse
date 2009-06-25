class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  self.allow_forgery_protection = false

  def test
    render :text => mce_in_place_tag(Page.create,'description','none')
  end
  
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  before_filter :check_user
  before_filter :setup_container
  
  protected
  
  def setup_container
    @container_type = self.class.controller_name.classify
    @container_id =  request.symbolized_path_parameters[:id]
  end
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
  
  private

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


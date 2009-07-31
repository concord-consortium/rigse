class ApplicationController < ActionController::Base
  include ExceptionNotifiable

  self.allow_forgery_protection = false

  def test
    render :text => mce_in_place_tag(Page.create,'description','none')
  end
  
  helper :all # include all helpers, all the time
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  before_filter :setup_container
  before_filter :setup_project
  
  protected
  
  def setup_container
    @container_type = self.class.controller_name.classify
    @container_id =  request.symbolized_path_parameters[:id]
  end
  
  def setup_project
    @project = Admin::Project.default_project
    @jnlp_adaptor = JnlpAdaptor.new(@project)
  end
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
  
  def get_scope(default)
    begin
      @scope = default
      if container_type = params[:scope_type]
        @scope = container_type.constantize.find(params[:scope_id])
      elsif container_type = params[:container_type] 
        @scope = container_type.constantize.find(params[:container_id])
      end
    rescue ActiveRecord::RecordNotFound
    end
  end

end


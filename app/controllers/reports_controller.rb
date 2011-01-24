class ReportsController < ApplicationController
  before_filter :login_required
  
  def index
  end
  
  def show
    unless %w( investigations resource_pages ).include?(params[:id])
      redirect_to :action => 'index' and return
    end
    
    if params[:id] == "investigations"
      @report_type = Investigation.display_name
    elsif params[:id] == "resource_pages"
      @report_type = ResourcePage.display_name
    end
    
  end

end

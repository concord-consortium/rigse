class ReportsController < ApplicationController
  before_filter :login_required
  
  def index
  end
  
  def show
    unless %w( investigations resource_pages ).include?(params[:id])
      redirect_to :action => 'index' and return
    end
    
    search_options = {
      :name => params[:name], 
      :portal_clazz_id => params[:portal_clazz_id],
      :grade_span => params[:grade_span],
      :domain_id => params[:domain_id],
      :paginate => !params[:print_mode],  # send params[:print_mode] for single-page view
      :page => params[:page] || 1
    }
    
    if params[:id] == "investigations"
      @report_type = Investigation.display_name
      @records = Investigation.search_list(search_options)
      
    elsif params[:id] == "resource_pages"
      @report_type = ResourcePage.display_name
      @records = ResourcePage.search_list(search_options)
    end
    
  end

end

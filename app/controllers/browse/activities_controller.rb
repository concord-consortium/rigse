class Browse::ActivitiesController < ApplicationController
  
  # GET /browse/activity/1
  def show
    @back_url = nil
    if request.post?
      @back_url = url_for :controller => '/search', :action => 'index',:search_term=>params["search_term"],:activity_page=>params["activity_page"],:investigation_page=>params["investigation_page"],:type=>"act"
    end
    
    @material = ::Activity.find(params[:id])
    if @material.teacher_only? && current_user.anonymous?
      flash[:notice] = 'Please log in as a teacher to see this content.'
    end
    
    @wide_content_layout = true
  end

end

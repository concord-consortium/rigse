class Browse::InvestigationsController < ApplicationController
 
  # GET /browse/investigations/1
  def show
    @back_url = nil
    if request.post?
      @back_url = url_for :controller => '/search', :action => 'index',:search_term=>params["search_term"],:activity_page=>params["activity_page"],:investigation_page=>params["investigation_page"],:type=>"inv"
    end
    @material = ::Investigation.find(params[:id])
    @wide_content_layout = true
    @page_title = @material.name
    @meta_title = @material.name
    if @material.description==""
      @meta_description = "Check out this great investigation from the Concord Consortium."
    else
      @meta_description = @material.description
    end
  end

end

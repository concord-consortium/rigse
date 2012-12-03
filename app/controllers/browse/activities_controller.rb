class Browse::ActivitiesController < ApplicationController
  
  # GET /browse/activity/1
  def show
    @back_url = nil
    if request.post?
      @back_url = url_for :controller => '/search', :action => 'index',:search_term=>params["search_term"],:activity_page=>params["activity_page"],:investigation_page=>params["investigation_page"],:type=>"act"
    end
    
    @wide_content_layout = true
    
    material = ::Activity.find(params[:id])
    if material.teacher_only && current_user.anonymous?
      flash.now[:notice] = 'Please log in as a teacher to see this content.'
    end
    
    @search_material = Search::SearchMaterial.new(material, current_user)
    
    #@search_material.set_page_title_and_meta_tags
    @page_title = @search_material.title
    @meta_title = @page_title
    
    @meta_description = @search_material.description
    if @meta_description.blank?
      @meta_description = "Check out this great activity from the Concord Consortium."
    end
    
    @og_title = @meta_title
    @og_type = 'website'
    @og_url = @search_material.url
    @og_image_url = url_for("/assets/#{@search_material.icon_image_url}")
    @og_description = @meta_description
    
  end

end

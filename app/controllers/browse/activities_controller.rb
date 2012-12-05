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
    @search_material.url = url_for(@search_material.url)
    @search_material.parent_material.url = url_for(@search_material.parent_material.url)
    
    page_meta = @search_material.get_page_title_and_meta_tags
    @page_title = page_meta[:title]
    @meta_tags = page_meta[:meta_tags]
    @open_graph = page_meta[:open_graph]
    
  end

end

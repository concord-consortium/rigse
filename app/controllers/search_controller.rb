class SearchController < ApplicationController

  in_place_edit_for :investigation, :search_term
  
  def index
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    search_options=get_investigation_searchoptions()
    @investigations = Investigation.search_list(search_options)
    @investigations_count = @investigations.length
    @investigations = @investigations.paginate(:page => params[:investigation_page]? params[:investigation_page] : 1, :per_page => 2) 
    activity_search_options=get_activity_searchoptions()
    @activities = Activity.search_list(activity_search_options)
    @activities_count = @activities.length
    @activities = @activities.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 2)
  end
  
  def show
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    
    search_options=get_investigation_searchoptions()
    investigations = Investigation.search_list(search_options)
    @investigations_count = investigations.length
    investigations = investigations.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 2)
    activity_search_options=get_activity_searchoptions()
    activities = Activity.search_list(activity_search_options)
    @activities_count = activities.length
    activities = activities.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 2)
    
    if request.xhr?
      render :update do |page| 
        page.replace_html 'offering_list', :partial => 'search/search_results',:locals=>{:investigations=>investigations,:activities=>activities}
        page << "$('suggestions').remove();"
      end
    else
      respond_to do |format|
        format.html do
            render 'index'
        end
        format.js
      end
    end
  end
  
  def get_investigation_searchoptions
    @search_term = params[:search_term]
    @sort_order = param_find(:sort_order, (params[:method] == :get))
    search_options = {
      :name => @search_term || '',
      :sort_order => @sort_order || 'name ASC',
      :paginate => false,
      #:page => params[:investigation_page] ? params[:investigation_page] : 1,
      #:per_page => 10
    }
    return search_options
  end

  def get_activity_searchoptions
    @search_term = params[:search_term]
    @sort_order = param_find(:sort_order, (params[:method] == :get))
    activity_search_options = {
      :name => @search_term || '',
      :sort_order => @sort_order || 'name ASC',
      :paginate => false,
      #:page => params[:activity_page] ? params[:activity_page] : 1,
      #:per_page => 10
    }
    return activity_search_options
  end
  
  def get_search_suggestions
    @search_term = params[:search_term]
    search_options = {
      :name => @search_term,
      :sort_order => 'name ASC'
    }
    
    investigations = Investigation.search_list(search_options)
    activities = Activity.search_list(search_options)
    @suggestions= [];
    @suggestions = investigations + activities
    if request.xhr?
       render :update do |page|
         page.replace_html 'search_suggestions', {:partial => 'search/search_suggestions',:locals=>{:textlength=>@search_term.length}}
       end
    end
  end
  
end

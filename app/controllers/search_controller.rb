class SearchController < ApplicationController

  in_place_edit_for :investigation, :search_term
  
  def index
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    
    @name = params[:search_term]
    @sort_order = param_find(:sort_order, (params[:method] == :get))
    
    search_options = {
      :name => @name|| "",
      :sort_order => @sort_order || 'created_at DESC',
      :paginate => false
      #:page => params[:investigation_page]? params[:investigation_page] : 1,
      #:per_page => 10
    }
    @investigations = Investigation.search_list(search_options)
    @investigations_count = @investigations.length
    @investigations = @investigations.paginate(:page => params[:investigation_page]? params[:activity_page] : 1, :per_page => 10) 
    activity_search_options = {
      :name => @name || "",
      :sort_order => @sort_order || 'created_at DESC',
      :paginate => false
      #:page => params[:activity_page]? params[:activity_page] : 1,
      #:per_page => 10
    }
    @activities = Activity.search_list(activity_search_options)
    @activities_count = @activities.length
    unless @investigations_count || @investigations_count
      @b_check=true
    end
    @activities = @activities.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 10)
  end
  
  def show
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    @name = params[:search_term]
    @sort_order = param_find(:sort_order, (params[:method] == :get))
    search_options = {
      :name => @name || '',
      :sort_order => @sort_order || 'created_at DESC',
      :paginate => false,
      #:page => params[:investigation_page] ? params[:investigation_page] : 1,
      #:per_page => 10
    }
    
    @investigations = Investigation.search_list(search_options)
    @investigations_count = @investigations.length
    if @investigations_count > 0
      @b_check = @b_check || true;
      @suggestions += @investigations
    else
      @b_check = @b_check || false;
    end
    @investigations = @investigations.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 10)
    
    activity_search_options = {
      :name => @name || '',
      :sort_order => @sort_order || 'created_at DESC',
      :paginate => false,
      #:page => params[:activity_page] ? params[:activity_page] : 1,
      #:per_page => 10
    }
    
      @activities = Activity.search_list(activity_search_options)
      @activities_count = @activities.length
      if @activities_count > 0
        @suggestions += @activities
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
      @activities = @activities.paginate(:page => params[:activity_page]? params[:activity_page] : 1, :per_page => 10)
    
    
    if request.xhr?
      render :update do |page| 
        page.replace_html 'offering_list', :partial => 'search/search_results'
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
  
  def get_search_suggestions
    @name = params[:search_term]
    search_options = {
      :name => @name,
      :sort_order => 'created_at DESC'
    }
    
    @investigations = Investigation.search_list(search_options)
    @activities = Activity.search_list(search_options)
    @suggestions= [];
    @suggestions = @investigations + @activities
    if request.xhr?
       render :update do |page|
         page.replace_html 'search_suggestions', {:partial => 'search/search_suggestions',:locals=>{:textlength=>@name.length}}
       end
    end
  end
  
end

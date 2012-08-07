class SearchController < ApplicationController

  in_place_edit_for :investigation, :search_term
  
  def index
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    search_options = {
      :sort_order => 'created_at DESC'
    }
    @investigations = Investigation.search_list(search_options)
    @activities = Activity.search_list(search_options)
    unless @investigations.nil? || @activities.nil?
      @b_check=true
    end
  end
  
  def show
    unless current_user.portal_teacher
      redirect_to root_path
      return
    end
    @name = params[:search_term]
    @suggestions = []
    @sort_order = param_find(:sort_order, (params[:method] == :get))
    search_options = {
      :name => @name,
      :sort_order => @sort_order || 'created_at DESC',
      :paginate => true
    }
    
    unless params[:investigation].nil?
      @investigations = Investigation.search_list(search_options) 
      if @investigations.length > 0
        @b_check = @b_check || true;
        @suggestions += @investigations
      else
        @b_check = @b_check || false;
      end
    end
    unless params[:activity].nil?
      @activities = Activity.search_list(search_options)
      if @activities.length > 0
        @suggestions += @activities
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
    end
    
    if request.xhr?
      render :update do |page| 
        @bshow = params[:show_suggestion]
        if @bshow=='true'
          page.replace_html 'search_suggestions', {:partial => 'search/search_suggestions',:locals=>{:textlength=>@name.length}}
        end
        page.replace_html 'offering_list', :partial => 'search/search_results'
        
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
end

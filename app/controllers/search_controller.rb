class SearchController < ApplicationController
  include RestrictedController
  in_place_edit_for :investigation, :name
  
  def index
     @b_check = false;
     @name = params[:name]
     @sort_order = param_find(:sort_order, (params[:method] == :get))
     search_options = {
      :name => @name,
      :sort_order => @sort_order || 'name ASC',
      :paginate => true,
    #  :page => pagination
    }
    
    unless params[:investigation].nil?
      @investigations = Investigation.search_list(search_options)
      if @investigations.length > 0
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
    end
    unless params[:activity].nil?  
      @activities = Activity.search_list(search_options)
      if @activities.length > 0
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
    end
    
    if request.xhr?
      #render :partial => 'search/filters'
     
    render :update do |page|
        page.replace_html 'offering_list', :partial => 'search/search_results' 
        page<<"$('suggestions').remove()"
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
  
  def show
     @name = params[:name]
     @sort_order = param_find(:sort_order, (params[:method] == :get))
     search_options = {
      :name => @name,
      :sort_order => @sort_order || 'name ASC',
      :paginate => true,
    #  :page => pagination
    }
    
    unless params[:investigation].nil?
      @investigations = Investigation.search_list(search_options) 
      if @investigations.length > 0
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
    end
    unless params[:activity].nil?  
      @activities = Activity.search_list(search_options)
      if @activities.length > 0
        @b_check = @b_check || true;
      else
        @b_check = @b_check || false;
      end
    end
    
    if request.xhr?
      render :update do |page|
        
        page.replace_html 'search_suggestions', {:partial => 'search/search_suggestions',:locals=>{:textlength=>@name.length}}
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

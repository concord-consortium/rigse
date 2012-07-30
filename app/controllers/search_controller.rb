class SearchController < ApplicationController
  include RestrictedController
  in_place_edit_for :investigation, :name
  
  def index
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
    end
    unless params[:activity].nil?  
      @activities = Activity.search_list(search_options)
    end
    
    if request.xhr?
      #render :partial => 'search/filters'
     
    render :update do |page|
        page.replace_html 'results', :partial => 'search/search_results' 
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
    end
    unless params[:activity].nil?  
      @activities = Activity.search_list(search_options)
    end
    
    if request.xhr?
      render :partial => 'search/search_results'
      
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

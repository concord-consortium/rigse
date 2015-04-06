class InteractivesController < ApplicationController
  def index
    @interactives = Interactive.paginate(:page => params[:page], :per_page => 30) 
  end
  
  def new
    @interactive = Interactive.new(:scale => 1.0, :width => 690, :height => 400)
  end
  
  def create
    @interactive = Interactive.new(params[:interactive])
    @interactive.user = current_visitor
    
    if params[:update_grade_levels]
      # set the grade_level tags
      @interactive.grade_level_list = (params[:grade_levels] || [])     
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @interactive.subject_area_list = (params[:subject_areas] || [])
    end

    if params[:update_model_types]
      # set the subject_area tags
      @interactive.model_type_list = (params[:model_types] || [])
    end

    respond_to do |format|
      if @interactive.save
        format.js  # render the js file
        flash[:notice] = 'Interactive was successfully created.'
        format.html { redirect_to(@interactive) }
        format.xml  { render :xml => @interactive, :status => :created, :location => @interactive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @interactive.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show 
    @interactive = Interactive.find(params[:id])
  end

  def edit
    @interactive = Interactive.find(params[:id])
  end

  def destroy
    @interactive = Interactive.find(params[:id])
    @interactive.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  def update
    cancel = params[:commit] == "Cancel"
    @interactive = Interactive.find(params[:id])

    if params[:update_grade_levels]
      # set the grade_level tags
      @interactive.grade_level_list = (params[:grade_levels] || [])
      @interactive.save
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @interactive.subject_area_list = (params[:subject_areas] || [])
      @interactive.save
    end

    if params[:update_model_types]
      # set the subject_area tags
      @interactive.model_type_list = (params[:model_types] || [])
      @interactive.save
    end

    if request.xhr?
      if cancel || @interactive.update_attributes(params[:interactive])
        render 'show', :locals => { :interactive => @interactive }
      else
        render :xml => @interactive.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @interactive.update_attributes(params[:interactive])
          flash[:notice] = 'Interactive was successfully updated.'
          format.html { redirect_to(@interactive) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @interactive.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
end

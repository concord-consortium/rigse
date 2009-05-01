class MultipleChoicesController < ApplicationController
  # GET /multiple_choices
  # GET /multiple_choices.xml
  def index    
    @multiple_choices = MultipleChoice.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @multiple_choices}
    end
  end

  # GET /multiple_choices/1
  # GET /multiple_choices/1.xml
  def show
    @multiple_choice = MultipleChoice.find(params[:id])
    if request.xhr?
      render :partial => 'multiple_choice', :locals => { :multiple_choice => @multiple_choice }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/multiple_choice" } # multiple_choice.otml.haml
        format.xml  { render :xml => @multiple_choice }
      end
    end
  end

  # GET /multiple_choices/1/print
  def print
    @multiple_choice = MultipleChoice.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @multiple_choice }
    end
  end

  # GET /multiple_choices/new
  # GET /multiple_choices/new.xml
  def new
    @multiple_choice = MultipleChoice.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :multiple_choice => @multiple_choice }
    else
      respond_to do |format|
        format.html { render :partial=>'multiple_choice', :locals => { :multiple_choice => @multiple_choice }, :layout=>false }
        format.xml  { render :xml => @multiple_choice }
      end
    end
  end

  # GET /multiple_choices/1/edit
  def edit
    @multiple_choice = MultipleChoice.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :multiple_choice => @multiple_choice }
    end
    
  end

  # POST /multiple_choices
  # POST /multiple_choices.xml
  def create
    @multiple_choice = MultipleChoice.new(params[:xhtml])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @multiple_choice.save
        render :partial => 'new', :locals => { :multiple_choice => @multiple_choice }
      else
        render :xml => @multiple_choice.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @multiple_choice.save
          flash[:notice] = 'Multiplechoice was successfully created.'
          format.html { redirect_to(@multiple_choice) }
          format.xml  { render :xml => @multiple_choice, :status => :created, :location => @multiple_choice }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /multiple_choices/1
  # PUT /multiple_choices/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @multiple_choice = MultipleChoice.find(params[:id])
    if request.xhr?
      if cancel || @multiple_choice.update_attributes(params[:multiple_choice])
        @multiple_choice.reload
        render :partial => 'show', :locals => { :multiple_choice => @multiple_choice }
      else
        render :xml => @multiple_choice.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:multiple_choice])
          flash[:notice] = 'Multiplechoice was successfully updated.'
          format.html { redirect_to(@multiple_choice) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # DELETE /multiple_choices/1
  # DELETE /multiple_choices/1.xml
  def destroy
    @multiple_choice = MultipleChoice.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(multiple_choices_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @multiple_choice.page_elements.each do |pe|
      pe.destroy
    end
    @multiple_choice.destroy    
  end
  
  def add_choice
    @question = MultipleChoice.find(params[:id])
    @choice = MultipleChoiceChoice.create
    # @question.choices << @choice
    @html_fragment = render_to_string(:partial => "new_choice", :locals => {:choice => @choice,:question => @question})
    respond_to do |format|
      # will render add_choice.js.rjs
      format.js
    end
  end
end

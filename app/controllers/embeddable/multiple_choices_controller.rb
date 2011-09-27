class Embeddable::MultipleChoicesController < ApplicationController
  # GET /Embeddable/multiple_choices
  # GET /Embeddable/multiple_choices.xml
  def index    
    @multiple_choices = Embeddable::MultipleChoice.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @multiple_choices}
    end
  end

  # GET /Embeddable/multiple_choices/1
  # GET /Embeddable/multiple_choices/1.xml
  def show
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :multiple_choice => @multiple_choice }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/multiple_choice" } # multiple_choice.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @multiple_choice , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @multiple_choice, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @multiple_choice, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @multiple_choice }
      end
    end
  end

  # GET /Embeddable/multiple_choices/new
  # GET /Embeddable/multiple_choices/new.xml
  def new
    @multiple_choice = Embeddable::MultipleChoice.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :multiple_choice => @multiple_choice }
    else
      respond_to do |format|
        format.html { render :partial=>'multiple_choice', :locals => { :multiple_choice => @multiple_choice }, :layout=>false }
        format.xml  { render :xml => @multiple_choice }
      end
    end
  end

  # GET /Embeddable/multiple_choices/1/edit
  def edit
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :multiple_choice => @multiple_choice }
    end
  end

  # POST /Embeddable/multiple_choices
  # POST /Embeddable/multiple_choices.xml
  def create
    @multiple_choice = Embeddable::MultipleChoice.new(params[:xhtml])
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

  # PUT /Embeddable/multiple_choices/1
  # PUT /Embeddable/multiple_choices/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    if request.xhr?
      if cancel || @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
        @multiple_choice.reload
        render :partial => 'show', :locals => { :multiple_choice => @multiple_choice }
      else
        render :xml => @multiple_choice.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
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
  
  # DELETE /Embeddable/multiple_choices/1
  # DELETE /Embeddable/multiple_choices/1.xml
  def destroy
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
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
    @question = Embeddable::MultipleChoice.find(params[:id])
    # dont use @question.addChoice or it will be added twice!!
    @choice = Embeddable::MultipleChoiceChoice.new(:choice => "new choice")
    @choice.save
    @html_fragment = render_to_string(:partial => "new_choice", :locals => {:choice => @choice,:question => @question})
    respond_to do |format|
      # will render add_choice.js.rjs
      format.js
    end
  end
end

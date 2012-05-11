class Embeddable::ImageQuestionsController < ApplicationController
  # GET /embeddable_image_questions
  # GET /embeddable_image_questions.xml
  def index    
    @image_questions = Embeddable::ImageQuestion.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @embeddable_image_questions}
    end
  end

  # GET /embeddable_image_questions/1
  # GET /embeddable_image_questions/1.xml
  def show
    @image_question = Embeddable::ImageQuestion.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :image_question => @image_question }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml   { render :layout => "layouts/embeddable/image_question" } # image_question.otml.haml
        format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @image_question } }

        format.config { render :partial => 'shared/show', :locals => { :runnable => @image_question, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @image_questionn } }
        format.xml    { render :image_question => @image_question }
      end
    end
  end

  # GET /embeddable_image_questions/new
  # GET /embeddable_image_questions/new.xml
  def new
    @image_question = Embeddable::ImageQuestion.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :image_question => @image_question }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @image_question }
      end
    end
  end

  # GET /embeddable_image_questions/1/edit
  def edit
    @image_question = Embeddable::ImageQuestion.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :image_question => @image_question }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @image_question  }
      end
    end
  end
  

  # POST /embeddable_image_questions
  # POST /embeddable_image_questions.xml
  def create
    @image_question = Embeddable::ImageQuestion.new(params[:image_question])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @image_question.save
        render :partial => 'new', :locals => { :image_question => @image_question }
      else
        render :xml => @image_question.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @image_question.save
          flash[:notice] = 'Embeddable::imagequestion was successfully created.'
          format.html { redirect_to(@image_question) }
          format.xml  { render :xml => @image_question, :status => :created, :location => @image_question }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @image_question.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /embeddable_image_questions/1
  # PUT /embeddable_image_questions/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @image_question = Embeddable::ImageQuestion.find(params[:id])
    if request.xhr?
      if cancel || @image_question.update_attributes(params[:embeddable_image_question])
        render :partial => 'show', :locals => { :image_question => @image_question }
      else
        render :xml => @image_question.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @image_question.update_attributes(params[:embeddable_image_question])
          flash[:notice] = 'Embeddable::imagequestion was successfully updated.'
          format.html { redirect_to(@image_question) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @image_question.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /embeddable_image_questions/1
  # DELETE /embeddable_image_questions/1.xml
  def destroy
    @image_question = Embeddable::ImageQuestion.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(image_questions_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @image_question.page_elements.each do |pe|
      pe.destroy
    end
    @image_question.destroy    
  end
end

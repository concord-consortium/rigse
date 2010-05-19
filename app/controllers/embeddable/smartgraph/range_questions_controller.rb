class Embeddable::Smartgraph::RangeQuestionsController < ApplicationController
  # GET /Embeddable/smartgraph_smartgraph_range_questions
  # GET /Embeddable/smartgraph_smartgraph_range_questions.xml
  def index    
    @smartgraph_range_questions = Embeddable::Smartgraph::RangeQuestion.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @smartgraph_range_questions}
    end
  end

  # GET /Embeddable/smartgraph_smartgraph_range_questions/1
  # GET /Embeddable/smartgraph_smartgraph_range_questions/1.xml
  def show
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :smartgraph_range_question => @smartgraph_range_question }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml   { render :layout => "layouts/embeddable/smartgraph/range_question" } # smartgraph_range_question.otml.haml
        format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @smartgraph_range_question , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @smartgraph_range_question, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @smartgraph_range_question , :teacher_mode => false } }
        format.xml    { render :smartgraph_range_question => @smartgraph_range_question }
      end
    end
  end

  # GET /Embeddable/smartgraph_smartgraph_range_questions/new
  # GET /Embeddable/smartgraph_smartgraph_range_questions/new.xml
  def new
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :smartgraph_range_question => @smartgraph_range_question }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @smartgraph_range_question }
      end
    end
  end

  # GET /Embeddable/smartgraph_smartgraph_range_questions/1/edit
  def edit
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.find(params[:id])
    @scope = get_scope(@smartgraph_range_question)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :smartgraph_range_question => @smartgraph_range_question }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @smartgraph_range_question  }
      end
    end
  end
  

  # POST /Embeddable/smartgraph_smartgraph_range_questions
  # POST /Embeddable/smartgraph_smartgraph_range_questions.xml
  def create
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.new(params[:smartgraph_smartgraph_range_question])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @smartgraph_range_question.save
        render :partial => 'new', :locals => { :smartgraph_range_question => @smartgraph_range_question }
      else
        render :xml => @smartgraph_range_question.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @smartgraph_range_question.save
          flash[:notice] = 'Smartgraph Range Question was successfully created.'
          format.html { redirect_to(@smartgraph_range_question) }
          format.xml  { render :xml => @smartgraph_range_question, :status => :created, :location => @smartgraph_range_question }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @smartgraph_range_question.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/smartgraph_smartgraph_range_questions/1
  # PUT /Embeddable/smartgraph_smartgraph_range_questions/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.find(params[:id])
    if request.xhr?
      if cancel || @smartgraph_range_question.update_attributes(params[:embeddable_smartgraph_smartgraph_range_question])
        render :partial => 'show', :locals => { :smartgraph_range_question => @smartgraph_range_question }
      else
        render :xml => @smartgraph_range_question.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @smartgraph_range_question.update_attributes(params[:embeddable_smartgraph_smartgraph_range_question])
          flash[:notice] = 'Smartgraph Range Question was successfully updated.'
          format.html { redirect_to(@smartgraph_range_question) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @smartgraph_range_question.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/smartgraph_smartgraph_range_questions/1
  # DELETE /Embeddable/smartgraph_smartgraph_range_questions/1.xml
  def destroy
    @smartgraph_range_question = Embeddable::Smartgraph::RangeQuestion.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(smartgraph_range_questions_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @smartgraph_range_question.page_elements.each do |pe|
      pe.destroy
    end
    @smartgraph_range_question.destroy    
  end
end

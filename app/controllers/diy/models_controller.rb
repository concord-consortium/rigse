class Diy::ModelsController < ApplicationController
  # GET /Embeddable/embedded_models
  # GET /Embeddable/embedded_models.xml
  def index
    @models = Diy::Model.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @models }
    end
  end

  # GET /Embeddable/embedded_models/1
  # GET /Embeddable/embedded_models/1.xml
  def show
    @model = Diy::Model.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :model => @model }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @model }
        format.otml { render :layout => 'layouts/diy/model' }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @model, :teacher_mode => false, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @model, :teacher_mode => false} }
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @model , :teacher_mode => false } }
      end
    end
  end

  # GET /Embeddable/embedded_models/new
  # GET /Embeddable/embedded_models/new.xml
  def new
    @model = Diy::Model.new
    @model.user = current_user
    @model.diy_id = 9999
    if request.xhr?
      render :partial => 'remote_form', :locals => { :model => @model }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @model }
      end
    end
  end

  # POST /Embeddable/embedded_models
  # POST /Embeddable/embedded_models.xml
  def create
    @model = Diy::Model.new(params[:diy_model])
    @model.user = current_user
    @model.diy_id = 9999
    @model.public = true
    @model.publication_status = "published"
    respond_to do |format|
      if @model.save
        flash[:notice] = 'Model was successfully created.'
        format.html { redirect_to(@model) }
        format.xml  { render :xml => @model, :status => :created, :location => @model }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /Embeddable/embedded_models/1/edit
  def edit
    @model = Diy::Model.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :model => @model }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @model }
      end
    end
  end
  
  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @model = Diy::Model.find(params[:id])
    respond_to do |format|
      if @model.update_attributes(params[:diy_model])
        flash[:notice] = 'Model was successfully updated.'
        format.html { redirect_to(@model) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Embeddable/embedded_models/1
  # DELETE /Embeddable/embedded_models/1.xml
  def destroy
    @model = Diy::Model.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(model_url) }
      format.xml  { head :ok }
      format.js
    end
    
    @model.destroy    
  end
end

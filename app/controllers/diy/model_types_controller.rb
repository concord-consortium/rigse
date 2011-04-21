class Diy::ModelTypesController < ApplicationController
  # GET /Embeddable/embedded_models
  # GET /Embeddable/embedded_models.xml
  def index
    @model_types = Diy::ModelType.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @model_type }
    end
  end

  # GET /Embeddable/embedded_models/1
  # GET /Embeddable/embedded_models/1.xml
  def show
    @model_type = Diy::ModelType.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :model_types => @model_type }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @model_type }
      end
    end
  end

  # GET /Embeddable/embedded_models/new
  # GET /Embeddable/embedded_models/new.xml
  def new
    @model_type = Diy::ModelType.new
    @model_type.user = current_user
    @model_type.diy_id = 9999
    if request.xhr?
      render :partial => 'remote_form', :locals => { :model_type => @model_type }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @model_type }
      end
    end
  end

  # GET /Embeddable/embedded_models/1/edit
  def edit
    @model_type = Diy::ModelType.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :model_type => @model_type }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @model_type }
      end
    end
  end

  # POST /Embeddable/embedded_models
  # POST /Embeddable/embedded_models.xml
  def create
    @model_type = Diy::ModelType.new(params[:diy_model_type])
    @model_type.user = current_user
    @model_type.diy_id = 9999
    @model_type.authorable = false
    respond_to do |format|
      if @model_type.save
        flash[:notice] = 'Model Type was successfully created.'
        format.html { redirect_to(@model_type) }
        format.xml  { render :xml => @model_type, :status => :created, :location => @model_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @model_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @model_type = Diy::ModelType.find(params[:id])
    respond_to do |format|
      if @model_type.update_attributes(params[:diy_model_type])
        flash[:notice] = 'Model Type was successfully updated.'
        format.html { redirect_to(@model_type) }
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
    @model_type = Diy::ModelType.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(model_types_url) }
      format.xml  { head :ok }
      format.js
    end
    
    @model_type.destroy    
  end
end

class Embeddable::WebModelsController < ApplicationController
  # GET /Embeddable/web_models
  # GET /Embeddable/web_models.xml
  def index
    @web_models = Embeddable::WebModel.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @web_models }
    end
  end

  # GET /Embeddable/web_models/1
  # GET /Embeddable/web_models/1.xml
  def show
    @web_model = Embeddable::WebModel.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :web_model => @web_model }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/web_model" } # web_model.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @web_model , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @web_model, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @web_model, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @web_model }
      end
    end
  end

  # GET /Embeddable/web_models/1/print
  def print
    @web_model = Embeddable::WebModel.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @web_model }
    end
  end

  # GET /Embeddable/web_models/new
  # GET /Embeddable/web_models/new.xml
  def new
    @web_model = Embeddable::WebModel.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :web_model => @web_model }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @web_model }
      end
    end
  end

  # GET /Embeddable/web_models/1/edit
  def edit
    @web_model = Embeddable::WebModel.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :web_model => @web_model }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @web_model }
      end
    end
  end

  # POST /Embeddable/web_models
  # POST /Embeddable/web_models.xml
  def create
    @web_model = Embeddable::WebModel.new(params[:web_model])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @web_model.save
        render :partial => 'new', :locals => { :web_model => @web_model }
      else
        render :xml => @web_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @web_model.save
          flash[:notice] = 'Embeddable::WebModel was successfully created.'
          format.html { redirect_to(@web_model) }
          format.xml  { render :xml => @web_model, :status => :created, :location => @web_model }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @web_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/web_models/1
  # PUT /Embeddable/web_models/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @web_model = Embeddable::WebModel.find(params[:id])
    if request.xhr?
      if cancel || @web_model.update_attributes(params[:embeddable_web_model])
        render :partial => 'show', :locals => { :web_model => @web_model }
      else
        render :xml => @web_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @web_model.update_attributes(params[:embeddable_web_model])
          flash[:notice] = 'Embeddable::WebModel was successfully updated.'
          format.html { redirect_to(@web_model) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @web_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/web_models/1
  # DELETE /Embeddable/web_models/1.xml
  def destroy
    @web_model = Embeddable::WebModel.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(web_models_url) }
      format.xml  { head :ok }
      format.js
    end

    # TODO:  We should move this logic into the model!
    @web_model.page_elements.each do |pe|
      pe.destroy
    end
    @web_model.destroy
  end
end

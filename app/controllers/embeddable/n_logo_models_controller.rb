class Embeddable::NLogoModelsController < ApplicationController
  # GET /Embeddable/n_logo_models
  # GET /Embeddable/n_logo_models.xml
  def index    
    @n_logo_models = Embeddable::NLogoModel.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @n_logo_models}
    end
  end

  # GET /Embeddable/n_logo_models/1
  # GET /Embeddable/n_logo_models/1.xml
  def show
    @n_logo_model = Embeddable::NLogoModel.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :n_logo_model => @n_logo_model }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/n_logo_model" } # n_logo_model.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @n_logo_model  } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @n_logo_model, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @n_logo_model} }
        format.xml  { render :n_logo_model => @n_logo_model }
      end
    end
  end

  # GET /Embeddable/n_logo_models/new
  # GET /Embeddable/n_logo_models/new.xml
  def new
    @n_logo_model = Embeddable::NLogoModel.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :n_logo_model => @n_logo_model }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @n_logo_model }
      end
    end
  end

  # GET /Embeddable/n_logo_models/1/edit
  def edit
    @n_logo_model = Embeddable::NLogoModel.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :n_logo_model => @n_logo_model }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @n_logo_model  }
      end
    end
  end
  

  # POST /Embeddable/n_logo_models
  # POST /Embeddable/n_logo_models.xml
  def create
    @n_logo_model = Embeddable::NLogoModel.new(params[:n_logo_model])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @n_logo_model.save
        render :partial => 'new', :locals => { :n_logo_model => @n_logo_model }
      else
        render :xml => @n_logo_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @n_logo_model.save
          flash[:notice] = 'Nlogomodel was successfully created.'
          format.html { redirect_to(@n_logo_model) }
          format.xml  { render :xml => @n_logo_model, :status => :created, :location => @n_logo_model }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @n_logo_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/n_logo_models/1
  # PUT /Embeddable/n_logo_models/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @n_logo_model = Embeddable::NLogoModel.find(params[:id])
    if request.xhr?
      if cancel || @n_logo_model.update_attributes(params[:embeddable_n_logo_model])
        render :partial => 'show', :locals => { :n_logo_model => @n_logo_model }
      else
        render :xml => @n_logo_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @n_logo_model.update_attributes(params[:embeddable_n_logo_model])
          flash[:notice] = 'Nlogomodel was successfully updated.'
          format.html { redirect_to(@n_logo_model) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @n_logo_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/n_logo_models/1
  # DELETE /Embeddable/n_logo_models/1.xml
  def destroy
    @n_logo_model = Embeddable::NLogoModel.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(n_logo_models_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @n_logo_model.page_elements.each do |pe|
      pe.destroy
    end
    @n_logo_model.destroy    
  end
end

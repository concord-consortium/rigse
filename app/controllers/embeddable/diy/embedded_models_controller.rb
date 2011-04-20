class Embeddable::Diy::EmbeddedModelsController < ApplicationController
  # GET /Embeddable/embedded_models
  # GET /Embeddable/embedded_models.xml
  def index
    @diy_embedded_models = Embeddable::Diy::EmbeddedModel.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diy_embedded_models }
    end
  end

  # GET /Embeddable/embedded_models/1
  # GET /Embeddable/embedded_models/1.xml
  def show
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :diy_embedded_model => @diy_embedded_model }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/embedded_model" } # embedded_model.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @diy_embedded_model , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @diy_embedded_model, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @diy_embedded_model, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @diy_embedded_model }
      end
    end
  end

  # GET /Embeddable/embedded_models/1/print
  def print
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @diy_embedded_model }
    end
  end

  # GET /Embeddable/embedded_models/new
  # GET /Embeddable/embedded_models/new.xml
  def new
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_embedded_model => @diy_embedded_model }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @diy_embedded_model }
      end
    end
  end

  # GET /Embeddable/embedded_models/1/edit
  def edit
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_embedded_model => @diy_embedded_model }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @diy_embedded_model }
      end
    end
  end

  # POST /Embeddable/embedded_models
  # POST /Embeddable/embedded_models.xml
  def create
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.new(params[:diy_embedded_model])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @diy_embedded_model.save
        render :partial => 'new', :locals => { :diy_embedded_model => @diy_embedded_model }
      else
        render :xml => @diy_embedded_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_embedded_model.save
          flash[:notice] = 'Embeddable::Diy::EmbeddedModel.was successfully created.'
          format.html { redirect_to(@diy_embedded_model) }
          format.xml  { render :xml => @diy_embedded_model, :status => :created, :location => @diy_embedded_model }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @diy_embedded_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/embedded_models/1
  # PUT /Embeddable/embedded_models/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.find(params[:id])
    @page_element = @diy_embedded_model.page_elements.first ## right now this is probably ok. if we ever embed the same embedded_model into multiple pages, we'll have to change this.
    if request.xhr?
      if cancel || @diy_embedded_model.update_attributes(params[:embeddable_diy_embedded_model])
        render :partial => params[:partial] || 'show', :locals => {:diy_embedded_model => @diy_embedded_model}
        #render(:update) do |page|
          #page.replace(dom_id_for(@diy_embedded_model, :details), :partial => 'show', :locals => { :diy_embedded_model => @diy_embedded_model } )
          #page.replace(dom_id_for(@page_element, :template_view_title), :partial => 'pages/template_view_title', :locals => {:page_element => @page_element})
        #end
      else
        render :xml => @diy_embedded_model.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_embedded_model.update_attributes(params[:embeddable_diy_embedded_model])
          flash[:notice] = 'Embeddable::Diy::EmbeddedModel.was successfully updated.'
          format.html { redirect_to(@diy_embedded_model) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @diy_embedded_model.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/embedded_models/1
  # DELETE /Embeddable/embedded_models/1.xml
  def destroy
    @diy_embedded_model = Embeddable::Diy::EmbeddedModel.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(embedded_models_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @diy_embedded_model.page_elements.each do |pe|
      pe.destroy
    end
    @diy_embedded_model.destroy    
  end
end

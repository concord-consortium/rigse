class BiologicaWorldsController < ApplicationController
  # GET /biologica_worlds
  # GET /biologica_worlds.xml
  def index    
    @biologica_worlds = BiologicaWorld.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_worlds}
    end
  end

  # GET /biologica_worlds/1
  # GET /biologica_worlds/1.xml
  def show
    @biologica_world = BiologicaWorld.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_world', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_world" } # biologica_world.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_world }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_world, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_world, :teacher_mode => @teacher_mode} }
        format.xml  { render :biologica_world => @biologica_world }
      end
    end
  end

  # GET /biologica_worlds/new
  # GET /biologica_worlds/new.xml
  def new
    @biologica_world = BiologicaWorld.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_world }
      end
    end
  end

  # GET /biologica_worlds/1/edit
  def edit
    @biologica_world = BiologicaWorld.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_world  }
      end
    end
  end
  

  # POST /biologica_worlds
  # POST /biologica_worlds.xml
  def create
    @biologica_world = BiologicaWorld.new(params[:biologica_world])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_world.save
        render :partial => 'new', :locals => { :biologica_world => @biologica_world }
      else
        render :xml => @biologica_world.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_world.save
          flash[:notice] = 'Biologicaworld was successfully created.'
          format.html { redirect_to(@biologica_world) }
          format.xml  { render :xml => @biologica_world, :status => :created, :location => @biologica_world }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_world.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /biologica_worlds/1
  # PUT /biologica_worlds/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_world = BiologicaWorld.find(params[:id])
    if request.xhr?
      if cancel || @biologica_world.update_attributes(params[:biologica_world])
        render :partial => 'show', :locals => { :biologica_world => @biologica_world }
      else
        render :xml => @biologica_world.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_world.update_attributes(params[:biologica_world])
          flash[:notice] = 'Biologicaworld was successfully updated.'
          format.html { redirect_to(@biologica_world) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_world.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /biologica_worlds/1
  # DELETE /biologica_worlds/1.xml
  def destroy
    @biologica_world = BiologicaWorld.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_worlds_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_world.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_world.destroy    
  end
end

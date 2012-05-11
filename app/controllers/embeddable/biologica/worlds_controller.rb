class Embeddable::Biologica::WorldsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_worlds
  # GET /Embeddable::Biologica/biologica_worlds.xml
  def index    
    @biologica_worlds = Embeddable::Biologica::World.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_worlds}
    end
  end

  # GET /Embeddable::Biologica/biologica_worlds/1
  # GET /Embeddable::Biologica/biologica_worlds/1.xml
  def show
    @biologica_world = Embeddable::Biologica::World.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/world" } # biologica_world.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_world  } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_world, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_world} }
        format.xml  { render :biologica_world => @biologica_world }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_worlds/new
  # GET /Embeddable::Biologica/biologica_worlds/new.xml
  def new
    @biologica_world = Embeddable::Biologica::World.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_world }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_worlds/1/edit
  def edit
    @biologica_world = Embeddable::Biologica::World.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_world => @biologica_world }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_world  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_worlds
  # POST /Embeddable::Biologica/biologica_worlds.xml
  def create
    @biologica_world = Embeddable::Biologica::World.new(params[:biologica_world])
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

  # PUT /Embeddable::Biologica/biologica_worlds/1
  # PUT /Embeddable::Biologica/biologica_worlds/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_world = Embeddable::Biologica::World.find(params[:id])
    if request.xhr?
      if cancel || @biologica_world.update_attributes(params[:embeddable_biologica_world])
        render :partial => 'show', :locals => { :biologica_world => @biologica_world }
      else
        render :xml => @biologica_world.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_world.update_attributes(params[:embeddable_biologica_world])
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

  # DELETE /Embeddable::Biologica/biologica_worlds/1
  # DELETE /Embeddable::Biologica/biologica_worlds/1.xml
  def destroy
    @biologica_world = Embeddable::Biologica::World.find(params[:id])
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

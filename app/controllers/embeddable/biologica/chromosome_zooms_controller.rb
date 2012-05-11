class Embeddable::Biologica::ChromosomeZoomsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_chromosome_zooms
  # GET /Embeddable::Biologica/biologica_chromosome_zooms.xml
  def index    
    @biologica_chromosome_zooms = Embeddable::Biologica::ChromosomeZoom.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_chromosome_zooms}
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosome_zooms/1
  # GET /Embeddable::Biologica/biologica_chromosome_zooms/1.xml
  def show
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/chromosome_zoom" } # biologica_chromosome_zoom.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_chromosome_zoom  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_chromosome_zoom, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_chromosome_zoom} }
        format.xml  { render :biologica_chromosome_zoom => @biologica_chromosome_zoom }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosome_zooms/new
  # GET /Embeddable::Biologica/biologica_chromosome_zooms/new.xml
  def new
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_chromosome_zoom }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosome_zooms/1/edit
  def edit
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.find(params[:id])
    @scope = get_scope(@biologica_chromosome_zoom)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_chromosome_zoom  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_chromosome_zooms
  # POST /Embeddable::Biologica/biologica_chromosome_zooms.xml
  def create
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.new(params[:biologica_chromosome_zoom])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_chromosome_zoom.save
        render :partial => 'new', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
      else
        render :xml => @biologica_chromosome_zoom.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome_zoom.save
          flash[:notice] = 'Biologicachromosomezoom was successfully created.'
          format.html { redirect_to(@biologica_chromosome_zoom) }
          format.xml  { render :xml => @biologica_chromosome_zoom, :status => :created, :location => @biologica_chromosome_zoom }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_chromosome_zoom.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable::Biologica/biologica_chromosome_zooms/1
  # PUT /Embeddable::Biologica/biologica_chromosome_zooms/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.find(params[:id])
    if request.xhr?
      if cancel || @biologica_chromosome_zoom.update_attributes(params[:embeddable_biologica_chromosome_zoom])
        render :partial => 'show', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
      else
        render :xml => @biologica_chromosome_zoom.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome_zoom.update_attributes(params[:embeddable_biologica_chromosome_zoom])
          flash[:notice] = 'Biologicachromosomezoom was successfully updated.'
          format.html { redirect_to(@biologica_chromosome_zoom) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_chromosome_zoom.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable::Biologica/biologica_chromosome_zooms/1
  # DELETE /Embeddable::Biologica/biologica_chromosome_zooms/1.xml
  def destroy
    @biologica_chromosome_zoom = Embeddable::Biologica::ChromosomeZoom.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_chromosome_zooms_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_chromosome_zoom.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_chromosome_zoom.destroy    
  end
end

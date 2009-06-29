class BiologicaChromosomeZoomsController < ApplicationController
  # GET /biologica_chromosome_zooms
  # GET /biologica_chromosome_zooms.xml
  def index    
    @biologica_chromosome_zooms = BiologicaChromosomeZoom.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_chromosome_zooms}
    end
  end

  # GET /biologica_chromosome_zooms/1
  # GET /biologica_chromosome_zooms/1.xml
  def show
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_chromosome_zoom', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_chromosome_zoom" } # biologica_chromosome_zoom.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @biologica_chromosome_zoom } }
        format.xml  { render :biologica_chromosome_zoom => @biologica_chromosome_zoom }
      end
    end
  end

  # GET /biologica_chromosome_zooms/new
  # GET /biologica_chromosome_zooms/new.xml
  def new
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_chromosome_zoom }
      end
    end
  end

  # GET /biologica_chromosome_zooms/1/edit
  def edit
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.find(params[:id])
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
  

  # POST /biologica_chromosome_zooms
  # POST /biologica_chromosome_zooms.xml
  def create
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.new(params[:biologica_chromosome_zoom])
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

  # PUT /biologica_chromosome_zooms/1
  # PUT /biologica_chromosome_zooms/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.find(params[:id])
    if request.xhr?
      if cancel || @biologica_chromosome_zoom.update_attributes(params[:biologica_chromosome_zoom])
        render :partial => 'show', :locals => { :biologica_chromosome_zoom => @biologica_chromosome_zoom }
      else
        render :xml => @biologica_chromosome_zoom.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome_zoom.update_attributes(params[:biologica_chromosome_zoom])
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

  # DELETE /biologica_chromosome_zooms/1
  # DELETE /biologica_chromosome_zooms/1.xml
  def destroy
    @biologica_chromosome_zoom = BiologicaChromosomeZoom.find(params[:id])
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

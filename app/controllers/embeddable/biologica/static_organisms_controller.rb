class Embeddable::Biologica::StaticOrganismsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_static_organisms
  # GET /Embeddable::Biologica/biologica_static_organisms.xml
  def index    
    @biologica_static_organisms = Embeddable::Biologica::StaticOrganism.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_static_organisms}
    end
  end

  # GET /Embeddable::Biologica/biologica_static_organisms/1
  # GET /Embeddable::Biologica/biologica_static_organisms/1.xml
  def show
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_static_organism => @biologica_static_organism }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/static_organism" } # biologica_static_organism.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_static_organism } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_static_organism, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_static_organism} }
        format.xml  { render :biologica_static_organism => @biologica_static_organism }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_static_organisms/new
  # GET /Embeddable::Biologica/biologica_static_organisms/new.xml
  def new
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_static_organism => @biologica_static_organism }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_static_organism }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_static_organisms/1/edit
  def edit
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.find(params[:id])
    @scope = get_scope(@biologica_static_organism)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_static_organism => @biologica_static_organism }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_static_organism  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_static_organisms
  # POST /Embeddable::Biologica/biologica_static_organisms.xml
  def create
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.new(params[:biologica_static_organism])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_static_organism.save
        render :partial => 'new', :locals => { :biologica_static_organism => @biologica_static_organism }
      else
        render :xml => @biologica_static_organism.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_static_organism.save
          flash[:notice] = 'Biologicastaticorganism was successfully created.'
          format.html { redirect_to(@biologica_static_organism) }
          format.xml  { render :xml => @biologica_static_organism, :status => :created, :location => @biologica_static_organism }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_static_organism.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable::Biologica/biologica_static_organisms/1
  # PUT /Embeddable::Biologica/biologica_static_organisms/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.find(params[:id])
    if request.xhr?
      if cancel || @biologica_static_organism.update_attributes(params[:embeddable_biologica_static_organism])
        render :partial => 'show', :locals => { :biologica_static_organism => @biologica_static_organism }
      else
        render :xml => @biologica_static_organism.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_static_organism.update_attributes(params[:embeddable_biologica_static_organism])
          flash[:notice] = 'Biologicastaticorganism was successfully updated.'
          format.html { redirect_to(@biologica_static_organism) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_static_organism.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable::Biologica/biologica_static_organisms/1
  # DELETE /Embeddable::Biologica/biologica_static_organisms/1.xml
  def destroy
    @biologica_static_organism = Embeddable::Biologica::StaticOrganism.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_static_organisms_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_static_organism.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_static_organism.destroy    
  end
end

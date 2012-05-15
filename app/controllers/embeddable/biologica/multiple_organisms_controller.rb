class Embeddable::Biologica::MultipleOrganismsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_multiple_organisms
  # GET /Embeddable::Biologica/biologica_multiple_organisms.xml
  def index    
    @biologica_multiple_organisms = Embeddable::Biologica::MultipleOrganism.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_multiple_organisms}
    end
  end

  # GET /Embeddable::Biologica/biologica_multiple_organisms/1
  # GET /Embeddable::Biologica/biologica_multiple_organisms/1.xml
  def show
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_multiple_organism => @biologica_multiple_organism }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/multiple_organism" } # biologica_multiple_organism.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_multiple_organism  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_multiple_organism, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_multiple_organism} }
        format.xml  { render :biologica_multiple_organism => @biologica_multiple_organism }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_multiple_organisms/new
  # GET /Embeddable::Biologica/biologica_multiple_organisms/new.xml
  def new
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_multiple_organism => @biologica_multiple_organism }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_multiple_organism }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_multiple_organisms/1/edit
  def edit
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.find(params[:id])
    @scope = get_scope(@biologica_multiple_organism)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_multiple_organism => @biologica_multiple_organism }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_multiple_organism  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_multiple_organisms
  # POST /Embeddable::Biologica/biologica_multiple_organisms.xml
  def create
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.new(params[:biologica_multiple_organism])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_multiple_organism.save
        render :partial => 'new', :locals => { :biologica_multiple_organism => @biologica_multiple_organism }
      else
        render :xml => @biologica_multiple_organism.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_multiple_organism.save
          flash[:notice] = 'Biologicamultipleorganism was successfully created.'
          format.html { redirect_to(@biologica_multiple_organism) }
          format.xml  { render :xml => @biologica_multiple_organism, :status => :created, :location => @biologica_multiple_organism }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_multiple_organism.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable::Biologica/biologica_multiple_organisms/1
  # PUT /Embeddable::Biologica/biologica_multiple_organisms/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.find(params[:id])
    if request.xhr?
      if cancel || @biologica_multiple_organism.update_attributes(params[:embeddable_biologica_multiple_organism])
        render :partial => 'show', :locals => { :biologica_multiple_organism => @biologica_multiple_organism }
      else
        render :xml => @biologica_multiple_organism.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_multiple_organism.update_attributes(params[:embeddable_biologica_multiple_organism])
          flash[:notice] = 'Biologicamultipleorganism was successfully updated.'
          format.html { redirect_to(@biologica_multiple_organism) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_multiple_organism.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable::Biologica/biologica_multiple_organisms/1
  # DELETE /Embeddable::Biologica/biologica_multiple_organisms/1.xml
  def destroy
    @biologica_multiple_organism = Embeddable::Biologica::MultipleOrganism.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_multiple_organisms_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_multiple_organism.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_multiple_organism.destroy    
  end
end

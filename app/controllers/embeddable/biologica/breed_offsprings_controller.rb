class Embeddable::Biologica::BreedOffspringsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_breed_offsprings
  # GET /Embeddable::Biologica/biologica_breed_offsprings.xml
  def index    
    @biologica_breed_offsprings = Embeddable::Biologica::BreedOffspring.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_breed_offsprings}
    end
  end

  # GET /Embeddable::Biologica/biologica_breed_offsprings/1
  # GET /Embeddable::Biologica/biologica_breed_offsprings/1.xml
  def show
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_breed_offspring=> @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/breed_offspring" } # biologica_breed_offspring.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_breed_offspring  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_breed_offspring, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_breed_offspring} }
        format.xml  { render :biologica_breed_offspring=> @biologica_breed_offspring }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_breed_offsprings/new
  # GET /Embeddable::Biologica/biologica_breed_offsprings/new.xml
  def new
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_breed_offspring=> @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_breed_offspring }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_breed_offsprings/1/edit
  def edit
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.find(params[:id])
    @scope = get_scope(@biologica_breed_offspring)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_breed_offspring=> @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_breed_offspring  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_breed_offsprings
  # POST /Embeddable::Biologica/biologica_breed_offsprings.xml
  def create
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.new(params[:biologica_breed_offspring])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_breed_offspring.save
        render :partial => 'new', :locals => { :biologica_breed_offspring=> @biologica_breed_offspring }
      else
        render :xml => @biologica_breed_offspring.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_breed_offspring.save
          flash[:notice] = 'Biologicabreedoffspring was successfully created.'
          format.html { redirect_to(@biologica_breed_offspring) }
          format.xml  { render :xml => @biologica_breed_offspring, :status => :created, :location => @biologica_breed_offspring }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_breed_offspring.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable::Biologica/biologica_breed_offsprings/1
  # PUT /Embeddable::Biologica/biologica_breed_offsprings/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.find(params[:id])
    if request.xhr?
      if cancel || @biologica_breed_offspring.update_attributes(params[:embeddable_biologica_breed_offspring])
        render :partial => 'show', :locals => { :biologica_breed_offspring=> @biologica_breed_offspring }
      else
        render :xml => @biologica_breed_offspring.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_breed_offspring.update_attributes(params[:embeddable_biologica_breed_offspring])
          flash[:notice] = 'Biologicabreedoffspring was successfully updated.'
          format.html { redirect_to(@biologica_breed_offspring) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_breed_offspring.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable::Biologica/biologica_breed_offsprings/1
  # DELETE /Embeddable::Biologica/biologica_breed_offsprings/1.xml
  def destroy
    @biologica_breed_offspring = Embeddable::Biologica::BreedOffspring.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_breed_offsprings_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_breed_offspring.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_breed_offspring.destroy    
  end
end

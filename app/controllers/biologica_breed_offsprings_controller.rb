class BiologicaBreedOffspringsController < ApplicationController
  # GET /biologica_breed_offsprings
  # GET /biologica_breed_offsprings.xml
  def index    
    @biologica_breed_offsprings = BiologicaBreedOffspring.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_breed_offsprings}
    end
  end

  # GET /biologica_breed_offsprings/1
  # GET /biologica_breed_offsprings/1.xml
  def show
    @biologica_breed_offspring = BiologicaBreedOffspring.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_breed_offspring', :locals => { :biologica_breed_offspring => @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_breed_offspring" } # biologica_breed_offspring.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_breed_offspring }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_breed_offspring, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_breed_offspring, :teacher_mode => @teacher_mode} }
        format.xml  { render :biologica_breed_offspring => @biologica_breed_offspring }
      end
    end
  end

  # GET /biologica_breed_offsprings/new
  # GET /biologica_breed_offsprings/new.xml
  def new
    @biologica_breed_offspring = BiologicaBreedOffspring.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_breed_offspring => @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_breed_offspring }
      end
    end
  end

  # GET /biologica_breed_offsprings/1/edit
  def edit
    @biologica_breed_offspring = BiologicaBreedOffspring.find(params[:id])
    @scope = get_scope(@biologica_breed_offspring)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_breed_offspring => @biologica_breed_offspring }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_breed_offspring  }
      end
    end
  end
  

  # POST /biologica_breed_offsprings
  # POST /biologica_breed_offsprings.xml
  def create
    @biologica_breed_offspring = BiologicaBreedOffspring.new(params[:biologica_breed_offspring])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_breed_offspring.save
        render :partial => 'new', :locals => { :biologica_breed_offspring => @biologica_breed_offspring }
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

  # PUT /biologica_breed_offsprings/1
  # PUT /biologica_breed_offsprings/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_breed_offspring = BiologicaBreedOffspring.find(params[:id])
    if request.xhr?
      if cancel || @biologica_breed_offspring.update_attributes(params[:biologica_breed_offspring])
        render :partial => 'show', :locals => { :biologica_breed_offspring => @biologica_breed_offspring }
      else
        render :xml => @biologica_breed_offspring.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_breed_offspring.update_attributes(params[:biologica_breed_offspring])
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

  # DELETE /biologica_breed_offsprings/1
  # DELETE /biologica_breed_offsprings/1.xml
  def destroy
    @biologica_breed_offspring = BiologicaBreedOffspring.find(params[:id])
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

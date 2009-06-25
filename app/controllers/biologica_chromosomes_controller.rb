class BiologicaChromosomesController < ApplicationController
  # GET /biologica_chromosomes
  # GET /biologica_chromosomes.xml
  def index    
    @biologica_chromosomes = BiologicaChromosome.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_chromosomes}
    end
  end

  # GET /biologica_chromosomes/1
  # GET /biologica_chromosomes/1.xml
  def show
    @biologica_chromosome = BiologicaChromosome.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_chromosome', :locals => { :biologica_chromosome => @biologica_chromosome }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_chromosome" } # biologica_chromosome.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @biologica_chromosome } }
        format.xml  { render :biologica_chromosome => @biologica_chromosome }
      end
    end
  end

  # GET /biologica_chromosomes/new
  # GET /biologica_chromosomes/new.xml
  def new
    @biologica_chromosome = BiologicaChromosome.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome => @biologica_chromosome }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_chromosome }
      end
    end
  end

  # GET /biologica_chromosomes/1/edit
  def edit
    @biologica_chromosome = BiologicaChromosome.find(params[:id])
    @scope = get_scope(@biologica_chromosome)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome => @biologica_chromosome }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_chromosome  }
      end
    end
  end
  

  # POST /biologica_chromosomes
  # POST /biologica_chromosomes.xml
  def create
    @biologica_chromosome = BiologicaChromosome.new(params[:biologica_chromosome])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_chromosome.save
        render :partial => 'new', :locals => { :biologica_chromosome => @biologica_chromosome }
      else
        render :xml => @biologica_chromosome.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome.save
          flash[:notice] = 'Biologicachromosome was successfully created.'
          format.html { redirect_to(@biologica_chromosome) }
          format.xml  { render :xml => @biologica_chromosome, :status => :created, :location => @biologica_chromosome }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_chromosome.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /biologica_chromosomes/1
  # PUT /biologica_chromosomes/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_chromosome = BiologicaChromosome.find(params[:id])
    if request.xhr?
      if cancel || @biologica_chromosome.update_attributes(params[:biologica_chromosome])
        render :partial => 'show', :locals => { :biologica_chromosome => @biologica_chromosome }
      else
        render :xml => @biologica_chromosome.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome.update_attributes(params[:biologica_chromosome])
          flash[:notice] = 'Biologicachromosome was successfully updated.'
          format.html { redirect_to(@biologica_chromosome) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_chromosome.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /biologica_chromosomes/1
  # DELETE /biologica_chromosomes/1.xml
  def destroy
    @biologica_chromosome = BiologicaChromosome.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_chromosomes_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_chromosome.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_chromosome.destroy    
  end
end

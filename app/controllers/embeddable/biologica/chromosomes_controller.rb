class Embeddable::Biologica::ChromosomesController < ApplicationController
  # GET /Embeddable::Biologica/biologica_chromosomes
  # GET /Embeddable::Biologica/biologica_chromosomes.xml
  def index    
    @biologica_chromosomes = Embeddable::Biologica::Chromosome.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_chromosomes}
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosomes/1
  # GET /Embeddable::Biologica/biologica_chromosomes/1.xml
  def show
    @biologica_chromosome = Embeddable::Biologica::Chromosome.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_chromosome=> @biologica_chromosome }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/chromosome" } # biologica_chromosome.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_chromosome, :teacher_mode => false  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_chromosome, :session_id => (params[:session] || request.env["rack.session.options"][:id]), :teacher_mode => false  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_chromosome, :teacher_mode => @teacher_mode} }
        format.xml  { render :biologica_chromosome=> @biologica_chromosome }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosomes/new
  # GET /Embeddable::Biologica/biologica_chromosomes/new.xml
  def new
    @biologica_chromosome = Embeddable::Biologica::Chromosome.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome=> @biologica_chromosome }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_chromosome }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_chromosomes/1/edit
  def edit
    @biologica_chromosome = Embeddable::Biologica::Chromosome.find(params[:id])
    @scope = get_scope(@biologica_chromosome)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_chromosome=> @biologica_chromosome }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_chromosome  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_chromosomes
  # POST /Embeddable::Biologica/biologica_chromosomes.xml
  def create
    @biologica_chromosome = Embeddable::Biologica::Chromosome.new(params[:biologica_chromosome])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_chromosome.save
        render :partial => 'new', :locals => { :biologica_chromosome=> @biologica_chromosome }
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

  # PUT /Embeddable::Biologica/biologica_chromosomes/1
  # PUT /Embeddable::Biologica/biologica_chromosomes/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_chromosome = Embeddable::Biologica::Chromosome.find(params[:id])
    if request.xhr?
      if cancel || @biologica_chromosome.update_attributes(params[:embeddable_biologica_chromosome])
        render :partial => 'show', :locals => { :biologica_chromosome=> @biologica_chromosome }
      else
        render :xml => @biologica_chromosome.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_chromosome.update_attributes(params[:embeddable_biologica_chromosome])
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

  # DELETE /Embeddable::Biologica/biologica_chromosomes/1
  # DELETE /Embeddable::Biologica/biologica_chromosomes/1.xml
  def destroy
    @biologica_chromosome = Embeddable::Biologica::Chromosome.find(params[:id])
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

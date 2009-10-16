class BiologicaPedigreesController < ApplicationController
  # GET /biologica_pedigrees
  # GET /biologica_pedigrees.xml
  def index    
    @biologica_pedigrees = BiologicaPedigree.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_pedigrees}
    end
  end

  # GET /biologica_pedigrees/1
  # GET /biologica_pedigrees/1.xml
  def show
    @biologica_pedigree = BiologicaPedigree.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_pedigree', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_pedigree" } # biologica_pedigree.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_pedigree }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_pedigree, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_pedigree, :teacher_mode => @teacher_mode} }
        format.xml  { render :biologica_pedigree => @biologica_pedigree }
      end
    end
  end

  # GET /biologica_pedigrees/new
  # GET /biologica_pedigrees/new.xml
  def new
    @biologica_pedigree = BiologicaPedigree.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_pedigree }
      end
    end
  end

  # GET /biologica_pedigrees/1/edit
  def edit
    @biologica_pedigree = BiologicaPedigree.find(params[:id])
    @scope = get_scope(@biologica_pedigree)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_pedigree  }
      end
    end
  end
  

  # POST /biologica_pedigrees
  # POST /biologica_pedigrees.xml
  def create
    @biologica_pedigree = BiologicaPedigree.new(params[:biologica_pedigree])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_pedigree.save
        render :partial => 'new', :locals => { :biologica_pedigree => @biologica_pedigree }
      else
        render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_pedigree.save
          flash[:notice] = 'Biologicapedigree was successfully created.'
          format.html { redirect_to(@biologica_pedigree) }
          format.xml  { render :xml => @biologica_pedigree, :status => :created, :location => @biologica_pedigree }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /biologica_pedigrees/1
  # PUT /biologica_pedigrees/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_pedigree = BiologicaPedigree.find(params[:id])
    if request.xhr?
      if cancel || @biologica_pedigree.update_attributes(params[:biologica_pedigree])
        render :partial => 'show', :locals => { :biologica_pedigree => @biologica_pedigree }
      else
        render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_pedigree.update_attributes(params[:biologica_pedigree])
          flash[:notice] = 'Biologicapedigree was successfully updated.'
          format.html { redirect_to(@biologica_pedigree) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /biologica_pedigrees/1
  # DELETE /biologica_pedigrees/1.xml
  def destroy
    @biologica_pedigree = BiologicaPedigree.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_pedigrees_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_pedigree.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_pedigree.destroy    
  end
end

class BiologicaMeiosisViewsController < ApplicationController
  # GET /biologica_meiosis_views
  # GET /biologica_meiosis_views.xml
  def index    
    @biologica_meiosis_views = BiologicaMeiosisView.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_meiosis_views}
    end
  end

  # GET /biologica_meiosis_views/1
  # GET /biologica_meiosis_views/1.xml
  def show
    @biologica_meiosis_view = BiologicaMeiosisView.find(params[:id])
    if request.xhr?
      render :partial => 'biologica_meiosis_view', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/biologica_meiosis_view" } # biologica_meiosis_view.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @biologica_meiosis_view } }
        format.xml  { render :biologica_meiosis_view => @biologica_meiosis_view }
      end
    end
  end

  # GET /biologica_meiosis_views/new
  # GET /biologica_meiosis_views/new.xml
  def new
    @biologica_meiosis_view = BiologicaMeiosisView.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_meiosis_view }
      end
    end
  end

  # GET /biologica_meiosis_views/1/edit
  def edit
    @biologica_meiosis_view = BiologicaMeiosisView.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_meiosis_view  }
      end
    end
  end
  

  # POST /biologica_meiosis_views
  # POST /biologica_meiosis_views.xml
  def create
    @biologica_meiosis_view = BiologicaMeiosisView.new(params[:biologica_meiosis_view])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_meiosis_view.save
        render :partial => 'new', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
      else
        render :xml => @biologica_meiosis_view.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_meiosis_view.save
          flash[:notice] = 'Biologicameiosisview was successfully created.'
          format.html { redirect_to(@biologica_meiosis_view) }
          format.xml  { render :xml => @biologica_meiosis_view, :status => :created, :location => @biologica_meiosis_view }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_meiosis_view.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /biologica_meiosis_views/1
  # PUT /biologica_meiosis_views/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_meiosis_view = BiologicaMeiosisView.find(params[:id])
    if request.xhr?
      if cancel || @biologica_meiosis_view.update_attributes(params[:biologica_meiosis_view])
        render :partial => 'show', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
      else
        render :xml => @biologica_meiosis_view.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_meiosis_view.update_attributes(params[:biologica_meiosis_view])
          flash[:notice] = 'Biologicameiosisview was successfully updated.'
          format.html { redirect_to(@biologica_meiosis_view) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_meiosis_view.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /biologica_meiosis_views/1
  # DELETE /biologica_meiosis_views/1.xml
  def destroy
    @biologica_meiosis_view = BiologicaMeiosisView.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_meiosis_views_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_meiosis_view.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_meiosis_view.destroy    
  end
end

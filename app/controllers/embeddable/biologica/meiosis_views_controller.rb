class Embeddable::Biologica::MeiosisViewsController < ApplicationController
  # GET /Embeddable::Biologica/biologica_meiosis_views
  # GET /Embeddable::Biologica/biologica_meiosis_views.xml
  def index    
    @biologica_meiosis_views = Embeddable::Biologica::MeiosisView.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_meiosis_views}
    end
  end

  # GET /Embeddable::Biologica/biologica_meiosis_views/1
  # GET /Embeddable::Biologica/biologica_meiosis_views/1.xml
  def show
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/meiosis_view" } # biologica_meiosis_view.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_meiosis_view  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_meiosis_view, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_meiosis_view} }
        format.xml  { render :biologica_meiosis_view => @biologica_meiosis_view }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_meiosis_views/new
  # GET /Embeddable::Biologica/biologica_meiosis_views/new.xml
  def new
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_meiosis_view }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_meiosis_views/1/edit
  def edit
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.find(params[:id])
    @scope = get_scope(@biologica_meiosis_view)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_meiosis_view  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_meiosis_views
  # POST /Embeddable::Biologica/biologica_meiosis_views.xml
  def create
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.new(params[:biologica_meiosis_view])
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

  # PUT /Embeddable::Biologica/biologica_meiosis_views/1
  # PUT /Embeddable::Biologica/biologica_meiosis_views/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.find(params[:id])
    if request.xhr?
      if cancel || @biologica_meiosis_view.update_attributes(params[:embeddable_biologica_meiosis_view])
        render :partial => 'show', :locals => { :biologica_meiosis_view => @biologica_meiosis_view }
      else
        render :xml => @biologica_meiosis_view.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_meiosis_view.update_attributes(params[:embeddable_biologica_meiosis_view])
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

  # DELETE /Embeddable::Biologica/biologica_meiosis_views/1
  # DELETE /Embeddable::Biologica/biologica_meiosis_views/1.xml
  def destroy
    @biologica_meiosis_view = Embeddable::Biologica::MeiosisView.find(params[:id])
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

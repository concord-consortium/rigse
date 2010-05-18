class Embeddable::MwModelerPagesController < ApplicationController
  # GET /Embeddable/mw_modeler_pages
  # GET /Embeddable/mw_modeler_pages.xml
  def index    
    @mw_modeler_pages = Embeddable::MwModelerPage.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mw_modeler_pages}
    end
  end

  # GET /Embeddable/mw_modeler_pages/1
  # GET /Embeddable/mw_modeler_pages/1.xml
  def show
    @mw_modeler_page = Embeddable::MwModelerPage.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :mw_modeler_page => @mw_modeler_page }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/mw_modeler_page" } # mw_modeler_page.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @mw_modeler_page , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @mw_modeler_page, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @mw_modeler_page, :teacher_mode => @teacher_mode} }
        format.xml  { render :mw_modeler_page => @mw_modeler_page }
      end
    end
  end

  # GET /Embeddable/mw_modeler_pages/new
  # GET /Embeddable/mw_modeler_pages/new.xml
  def new
    @mw_modeler_page = Embeddable::MwModelerPage.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :mw_modeler_page => @mw_modeler_page }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @mw_modeler_page }
      end
    end
  end

  # GET /Embeddable/mw_modeler_pages/1/edit
  def edit
    @mw_modeler_page = Embeddable::MwModelerPage.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :mw_modeler_page => @mw_modeler_page }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @mw_modeler_page  }
      end
    end
  end
  

  # POST /Embeddable/mw_modeler_pages
  # POST /Embeddable/mw_modeler_pages.xml
  def create
    @mw_modeler_page = Embeddable::MwModelerPage.new(params[:mw_modeler_page])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @mw_modeler_page.save
        render :partial => 'new', :locals => { :mw_modeler_page => @mw_modeler_page }
      else
        render :xml => @mw_modeler_page.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @mw_modeler_page.save
          flash[:notice] = 'Mwmodelerpage was successfully created.'
          format.html { redirect_to(@mw_modeler_page) }
          format.xml  { render :xml => @mw_modeler_page, :status => :created, :location => @mw_modeler_page }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @mw_modeler_page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/mw_modeler_pages/1
  # PUT /Embeddable/mw_modeler_pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @mw_modeler_page = Embeddable::MwModelerPage.find(params[:id])
    if request.xhr?
      if cancel || @mw_modeler_page.update_attributes(params[:embeddable_mw_modeler_page])
        render :partial => 'show', :locals => { :mw_modeler_page => @mw_modeler_page }
      else
        render :xml => @mw_modeler_page.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @mw_modeler_page.update_attributes(params[:embeddable_mw_modeler_page])
          flash[:notice] = 'Mwmodelerpage was successfully updated.'
          format.html { redirect_to(@mw_modeler_page) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @mw_modeler_page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/mw_modeler_pages/1
  # DELETE /Embeddable/mw_modeler_pages/1.xml
  def destroy
    @mw_modeler_page = Embeddable::MwModelerPage.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(mw_modeler_pages_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @mw_modeler_page.page_elements.each do |pe|
      pe.destroy
    end
    @mw_modeler_page.destroy    
  end
end

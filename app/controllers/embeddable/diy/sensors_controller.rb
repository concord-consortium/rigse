class Embeddable::XhtmlsController < ApplicationController
  # GET /Embeddable/xhtmls
  # GET /Embeddable/xhtmls.xml
  def index
    @xhtmls = Embeddable::Xhtml.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @xhtmls }
    end
  end

  # GET /Embeddable/xhtmls/1
  # GET /Embeddable/xhtmls/1.xml
  def show
    @xhtml = Embeddable::Xhtml.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/xhtml" } # xhtml.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @xhtml , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @xhtml, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @xhtml, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # GET /Embeddable/xhtmls/1/print
  def print
    @xhtml = Embeddable::Xhtml.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @xhtml }
    end
  end

  # GET /Embeddable/xhtmls/new
  # GET /Embeddable/xhtmls/new.xml
  def new
    @xhtml = Embeddable::Xhtml.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # GET /Embeddable/xhtmls/1/edit
  def edit
    @xhtml = Embeddable::Xhtml.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # POST /Embeddable/xhtmls
  # POST /Embeddable/xhtmls.xml
  def create
    @xhtml = Embeddable::Xhtml.new(params[:xhtml])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @xhtml.save
        render :partial => 'new', :locals => { :xhtml => @xhtml }
      else
        render :xml => @xhtml.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @xhtml.save
          flash[:notice] = 'Embeddable::Xhtml.was successfully created.'
          format.html { redirect_to(@xhtml) }
          format.xml  { render :xml => @xhtml, :status => :created, :location => @xhtml }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/xhtmls/1
  # PUT /Embeddable/xhtmls/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @xhtml = Embeddable::Xhtml.find(params[:id])
    if request.xhr?
      if cancel || @xhtml.update_attributes(params[:embeddable_xhtml])
        render :partial => 'show', :locals => { :xhtml => @xhtml }
      else
        render :xml => @xhtml.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @xhtml.update_attributes(params[:embeddable_xhtml])
          flash[:notice] = 'Embeddable::Xhtml.was successfully updated.'
          format.html { redirect_to(@xhtml) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/xhtmls/1
  # DELETE /Embeddable/xhtmls/1.xml
  def destroy
    @xhtml = Embeddable::Xhtml.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(xhtmls_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @xhtml.page_elements.each do |pe|
      pe.destroy
    end
    @xhtml.destroy    
  end
end

class XhtmlsController < ApplicationController
  # GET /xhtmls
  # GET /xhtmls.xml
  def index    
    @xhtmls = Xhtml.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @xhtmls }
    end
  end

  # GET /xhtmls/1
  # GET /xhtmls/1.xml
  def show
    @xhtml = Xhtml.find(params[:id])
    if request.xhr?
      render :partial => 'xhtml', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/xhtml" } # xhtml.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @xhtml } }
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # GET /xhtmls/1/print
  def print
    @xhtml = Xhtml.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @xhtml }
    end
  end

  # GET /xhtmls/new
  # GET /xhtmls/new.xml
  def new
    @xhtml = Xhtml.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # GET /xhtmls/1/edit
  def edit
    @xhtml = Xhtml.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :xhtml => @xhtml }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @xhtml }
      end
    end
  end

  # POST /xhtmls
  # POST /xhtmls.xml
  def create
    @xhtml = Xhtml.new(params[:xhtml])
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
          flash[:notice] = 'Xhtml was successfully created.'
          format.html { redirect_to(@xhtml) }
          format.xml  { render :xml => @xhtml, :status => :created, :location => @xhtml }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /xhtmls/1
  # PUT /xhtmls/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @xhtml = Xhtml.find(params[:id])
    if request.xhr?
      if cancel || @xhtml.update_attributes(params[:xhtml])
        render :partial => 'show', :locals => { :xhtml => @xhtml }
      else
        render :xml => @xhtml.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @xhtml.update_attributes(params[:xhtml])
          flash[:notice] = 'Xhtml was successfully updated.'
          format.html { redirect_to(@xhtml) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /xhtmls/1
  # DELETE /xhtmls/1.xml
  def destroy
    @xhtml = Xhtml.find(params[:id])
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

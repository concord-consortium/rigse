class InnerPagesController < ApplicationController
  # GET /inner_pages
  # GET /inner_pages.xml
  def index    
    @inner_pages = InnerPage.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inner_pages}
    end
  end

  
  def add_page
    @inner_page = InnerPage.find(params['id'])
    @new_page = Page.create
    @new_page.user = current_user
    @inner_page << @new_page
    render :partial => "page", :locals => {:sub_page => @new_page, :inner_page => @inner_page}
  end
  
  def delete_page
    @inner_page = InnerPage.find(params['id'])
    @page = Page.find(params['page_id'])
    last_number = @page.page_number
    last_number = last_number - 1 
    @inner_page.delete_page(@page)
    last_number = last_number > 1 ? (last_number -1) : 0
    @page = @inner_page.sub_pages[last_number]
    if (@page)
       render :partial => "page", :locals => {:sub_page => @inner_page.sub_pages[last_number], :inner_page => @inner_page}
    else
     render :text => "<div></div>"
    end
  end

  def set_page
    @inner_page = InnerPage.find(params['id'])
    @page = Page.find(params['page_id'])
    render :partial => "page", :locals => {:sub_page => @page, :inner_page => @inner_page}
  end


  ##
  ## TODO: This code was copy/pasted from the pages controller.
  ## TODO: It should be DRYd up a bit.
  ## This is a remote_function (ajax) to be called with link_to_remote or similar. 
  ## We expect parameters "page_id" and "closs_name"
  ## optional parameter "container" tells us what DOM ID to add our results too...
  ##
  def add_element
    @inner_page = InnerPage.find(params['id'])
    @page = Page.find(params['page_id'])
    @container = params['container'] || 'elements_container'

    # dynamically instantiate the component based on its type.
    component_class = Kernel.const_get(params['class_name'])
    if component_class == DataCollector
      if probe_type_id = session[:last_saved_probe_type_id]
        probe_type = ProbeType.find(probe_type_id)
        @component = DataCollector.new
        @component.probe_type = probe_type
        @component.save
      else
        @component = DataCollector.create
      end
      session[:last_saved_probe_type_id] = @component.probe_type_id
    else
      @component = component_class.create
    end
    @component.pages << @page
    @component.user = current_user
    @component.save
    @element = @page.element_for(@component)
    @element.user = current_user
    @element.save
    # @element.update_investigation_timestamp
    @page.reload
    render :partial => "page", :locals => {:sub_page => @page, :inner_page => @inner_page}
  end



  
  # GET /inner_pages/1
  # GET /inner_pages/1.xml
  def show
    @inner_page = InnerPage.find(params[:id])
    @page = @inner_page.children[0]
    if request.xhr?
      render :partial => 'inner_page', :locals => { :inner_page => @inner_page }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/inner_page" } # inner_page.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @inner_page } }
        format.xml  { render :inner_page => @inner_page }
      end
    end
  end

  # GET /inner_pages/new
  # GET /inner_pages/new.xml
  def new
    @inner_page = InnerPage.new
    @inner_page.user = current_user
    if request.xhr?
      render :partial => 'remote_form', :locals => { :inner_page => @inner_page }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @inner_page }
      end
    end
  end

  # GET /inner_pages/1/edit
  def edit
    @inner_page = InnerPage.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :inner_page => @inner_page }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @inner_page  }
      end
    end
  end
  

  # POST /inner_pages
  # POST /inner_pages.xml
  def create
    @inner_page = InnerPage.new(params[:inner_page])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @inner_page.save
        render :partial => 'new', :locals => { :inner_page => @inner_page }
      else
        render :xml => @inner_page.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @inner_page.save
          flash[:notice] = 'Innerpage was successfully created.'
          format.html { redirect_to(@inner_page) }
          format.xml  { render :xml => @inner_page, :status => :created, :location => @inner_page }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @inner_page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /inner_pages/1
  # PUT /inner_pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @inner_page = InnerPage.find(params[:id])
    if request.xhr?
      if cancel || @inner_page.update_attributes(params[:inner_page])
        render :partial => 'show', :locals => { :inner_page => @inner_page }
      else
        render :xml => @inner_page.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @inner_page.update_attributes(params[:inner_page])
          flash[:notice] = 'Innerpage was successfully updated.'
          format.html { redirect_to(@inner_page) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @inner_page.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /inner_pages/1
  # DELETE /inner_pages/1.xml
  def destroy
    @inner_page = InnerPage.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(inner_pages_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @inner_page.page_elements.each do |pe|
      pe.destroy
    end
    @inner_page.destroy    
  end
end

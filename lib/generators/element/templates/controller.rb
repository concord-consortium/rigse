class <%= controller_class_name %>Controller < ApplicationController
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index    
    @<%= table_name %> = <%= class_name %>.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %>}
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if request.xhr?
      render :partial => '<%= singular_name %>', :locals => { :<%= singular_name %> => @<%= singular_name %> }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml   { render :layout => "layouts/<%= singular_name %>" } # <%= singular_name %>.otml.haml
        format.jnlp   { render :partial => 'shared/installer', :locals => { :runnable => @<%= singular_name %> } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @<%= singular_name %>, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @<%= singular_name %> } }
        format.xml    { render :<%= singular_name %> => @<%= singular_name %> }
      end
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= singular_name %> = <%= class_name %>.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :<%= singular_name %> => @<%= singular_name %> }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @<%= singular_name %> }
      end
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :<%= singular_name %> => @<%= singular_name %> }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @<%= singular_name %>  }
      end
    end
  end
  

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @<%= singular_name %>.save
        render :partial => 'new', :locals => { :<%= singular_name %> => @<%= singular_name %> }
      else
        render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @<%= singular_name %>.save
          flash[:notice] = '<%= class_name.humanize %> was successfully created.'
          format.html { redirect_to(@<%= singular_name %>) }
          format.xml  { render :xml => @<%= singular_name %>, :status => :created, :location => @<%= singular_name %> }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if request.xhr?
      if cancel || @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        render :partial => 'show', :locals => { :<%= singular_name %> => @<%= singular_name %> }
      else
        render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
          flash[:notice] = '<%= class_name.humanize %> was successfully updated.'
          format.html { redirect_to(@<%= singular_name %>) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(<%= plural_name %>_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @<%= singular_name %>.page_elements.each do |pe|
      pe.destroy
    end
    @<%= singular_name %>.destroy    
  end
end

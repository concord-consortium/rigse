class XhtmlsController < ApplicationController
  # GET /drawing_tools
  # GET /drawing_tools.xml
  def index    
    @drawing_tools = DrawingTool.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @drawing_tools}
    end
  end

  # GET /drawing_tools/1
  # GET /drawing_tools/1.xml
  def show
    @drawing_tool = %= class_name %>.find(params[:id])
    if request.xhr?
      render :partial => 'drawing_tool', :locals => { :drawing_tool => @drawing_tool }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @drawing_tool }
      end
    end
  end

  # GET /drawing_tools/new
  # GET /drawing_tools/new.xml
  def new
    @drawing_tool = DrawingTool.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :drawing_tool => @drawing_tool }
    else
      respond_to do |format|
        format.html { render :partial=>'drawing_tool', :locals => { :drawing_tool => @drawing_tool }, :layout=>false }
        format.xml  { render :xml => @drawing_tool }
      end
    end
  end

  # GET /drawing_tools/1/edit
  def edit
    @drawing_tool = DrawingTool.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :drawing_tool => @drawing_tool }
    end
    
  end

  # POST /drawing_tools
  # POST /drawing_tools.xml
  def create
    @drawing_tool = DrawingTool.new(params[:xhtml])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @drawing_tool.save
        render :partial => 'new', :locals => { :drawing_tool => @drawing_tool }
      else
        render :xml => @drawing_tool.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @drawing_tool.save
          flash[:notice] = 'Drawingtool was successfully created.'
          format.html { redirect_to(@drawing_tool) }
          format.xml  { render :xml => @drawing_tool, :status => :created, :location => @drawing_tool }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @drawing_tool.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /drawing_tools/1
  # PUT /drawing_tools/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @drawing_tool = DrawingTool.find(params[:id])
    if request.xhr?
      if cancel || @drawing_tool.update_attributes(params[:drawing_tool])
        render :partial => 'show', :locals => { :drawing_tool => @drawing_tool }
      else
        render :xml => @drawing_tool.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @drawing_tool.update_attributes(params[:drawing_tool])
          flash[:notice] = 'Drawingtool was successfully updated.'
          format.html { redirect_to(@drawing_tool) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @drawing_tool.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /drawing_tools/1
  # DELETE /drawing_tools/1.xml
  def destroy
    @drawing_tool = DrawingTool.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(drawing_tools_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @drawing_tool.page_elements.each do |pe|
      pe.destroy
    end
    @drawing_tool.destroy    
  end
end

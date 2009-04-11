class InvestigationsController < ApplicationController
  # GET /pages
  # GET /pages.xml
  
  prawnto :prawn=>{
    :page_layout=>:landscape,
  }
  
  before_filter :setup_object, :except => [:index, :add_step]
  
  protected
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @investigation = Investigation.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @investigation = Investigation.find(params[:id])
      end
    elsif params[:investigation]
      @investigation = Investigation.new(params[:investigation])
    else
      @investigation = Investigation.new
    end
  end
  
  public
  
  def index
    @pages = Investigation.search(params[:search], params[:page], self.current_user)
    @paginated_objects = @pages
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @investigation = Investigation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @investigation }
      format.pdf {render :layout => false }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @investigation = Investigation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /pages/1/edit
  def edit
    @investigation = Investigation.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :investigation => @investigation }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @investigation = Investigation.new(params[:investigation])

    respond_to do |format|
      if @investigation.save
        flash[:notice] = 'Investigation was successfully created.'
        format.html { redirect_to(@investigation) }
        format.xml  { render :xml => @investigation, :status => :created, :location => @investigation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @investigation = Investigation.find(params[:id])
    if request.xhr?
      if cancel || @investigation.update_attributes(params[:investigation])
        render :partial => 'shared/investigation_header', :locals => { :investigation => @investigation }
      else
        render :xml => @investigation.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @investigation.update_attributes(params[:investigation])
          flash[:notice] = 'Investigation was successfully updated.'
          format.html { redirect_to(@investigation) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @investigation = Investigation.find(params[:id])
    @investigation.destroy

    respond_to do |format|
      format.html { redirect_to(investigations_url) }
      format.xml  { head :ok }
    end
  end
  
  ##
  ##
  ##
  def add_section
    @section = Section.new
    @investigation = Investigation.find(params['id'])
    @section.investigation = @investigation
  end
  
  ##
  ##
  ##  
  def sort_sections
    @investigation = Investigation.find(params[:id], :include => :sections)
    @investigation.sections.each do |section|
      section.position = params['investigation_sections_list'].index(section.id.to_s) + 1
      section.save
    end 
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_section
    @section= Section.find(params['section_id'])
    @section.destroy
  end  
  
  ##
  ##
  ##
  def duplicate
    @original = Investigation.find(params['id'])
    @investigation = @original.clone
    @investigation.save
    redirect_to edit_investigation_url(@investigation)
  end
  
end

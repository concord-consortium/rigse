class SectionsController < ApplicationController
  
  before_filter :find_entities, :except => 'create'
  protected 
  
  def find_entities
    # @investigation = Investigation.find(params[:section_id])
    @section = Section.find(params[:id])
  end
  
  public
  
  ##
  ##
  ##
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def new
    @section = Section.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def create
    @section = Section.create!(params[:section])
    respond_to do |format|
      format.js {
        @page = Page.create
        @xhtml = Xhtml.create
        @xhtml.pages << @page
        @section.pages << @page
        @section.save
      }
      format.html { 
        flash[:notice] = 'Section was successfully created.'
        redirect_to(@section) }
      format.xml  { render :xml => @section, :status => :created, :location => @section }
    end
  end

  # GET /pages/1/edit
  def edit
    @section = Section.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :section => @section, :investigation => @section.investigation }
    end
  end
  
  ##
  ##
  ##
  def update
    @section = Section.find(params[:id])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if @section.update_attributes(params[:section])
        render :partial => 'shared/section_header', :locals => { :section => @section }
      else
        render :xml => @section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @section.update_attributes(params[:section])
          flash[:notice] = 'Section was successfully updated.'
          format.html { redirect_to(@section) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  ##
  ##
  ##
  def destroy
    @section = Section.find(params[:id])
    @section.destroy
    respond_to do |format|
      format.html { redirect_to(page_url) }
      format.xml  { head :ok }
    end
  end


  ##
  ##
  ##
  def add_page
    @page= Page.new
    if (params['id']) 
      @section = Section.find(params['id'])
      @page.section = @section
    end
  end
  
  ##
  ##
  ##  
  def sort_pages
    @section = Section.find(params[:id], :include => :pages)
    @section.pages.each do |page|
      page.position = params['section_pages_list'].index(page.id.to_s) + 1
      page.save
    end 
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_page
    @page= Page.find(params['page_id'])
    @page.destroy
  end
  
  
  ##
  ##
  ##
  def duplicate
    @original = Section.find(params['id'])
    @section = @original.clone :include => {:pages => {:page_elements => :embeddable}}
    @section.name = "copy of #{@original.name}"
    @section.save
    @investigation = @section.investigation
    redirect_to :action => 'edit', :id => @section.id
  end
  
end

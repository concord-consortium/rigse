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
      format.js
      format.html { 
        flash[:notice] = 'Section was successfully created.'
        redirect_to(@section) }
      format.xml  { render :xml => @section, :status => :created, :location => @section }
    end
  end

  ##
  ##
  ##
  def update
    @section = Section.find(params[:id])
    respond_to do |format|
      if @section.update_attributes(params[:page])
        flash[:notice] = 'Section was successfully updated.'
        format.html { redirect_to(@section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
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
    @page.section = Section.find(params[:id])
    @page.save
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
end

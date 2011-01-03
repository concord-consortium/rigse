class Embeddable::Diy::SectionsController < ApplicationController
  # GET /Embeddable/sections
  # GET /Embeddable/sections.xml
  def index
    @sections = Embeddable::Diy::Section.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @sections }
    end
  end

  # GET /Embeddable/sections/1
  # GET /Embeddable/section/1.xml
  def show
    @section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :section => @section }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/section" } # section.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @section , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @section, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @section, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @section }
      end
    end
  end

  # GET /Embeddable/section/1/print
  def print
    @section = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @section }
    end
  end

  # GET /Embeddable/section/new
  # GET /Embeddable/section/new.xml
  def new
    @section = Embeddable::Diy::Section.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :section => @section }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @section }
      end
    end
  end

  # GET /Embeddable/section/1/edit
  def edit
    @section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :section => @section }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @section }
      end
    end
  end

  # POST /Embeddable/sections
  # POST /Embeddable/section.xml
  def create
    @section = Embeddable::Diy::Section.new(params[:embeddable_diy_section])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @section.save
        render :partial => 'new', :locals => { :section => @section }
      else
        render :xml => @section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @section.save
          flash[:notice] = 'Embeddable::Diy::Section.was successfully created.'
          format.html { redirect_to(@section) }
          format.xml  { render :xml => @section, :status => :created, :location => @section }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/section/1
  # PUT /Embeddable/section/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      if cancel || @section.update_attributes(params[:embeddable_diy_section])
        render :partial => 'show', :locals => { :section => @section }
      else
        render :xml => @section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @section.update_attributes(params[:embeddable_diy_section])
          flash[:notice] = 'Embeddable::Diy::Section.was successfully updated.'
          format.html { redirect_to(@section) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/section/1
  # DELETE /Embeddable/section/1.xml
  def destroy
    @section = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(section_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @section.page_elements.each do |pe|
      pe.destroy
    end
    @section.destroy    
  end
end

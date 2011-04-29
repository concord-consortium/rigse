class Embeddable::Diy::SectionsController < ApplicationController
  # GET /Embeddable/sections
  # GET /Embeddable/sections.xml
  def index
    @diy_sections = Embeddable::Diy::Section.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @diy_sections }
    end
  end

  # GET /Embeddable/sections/1
  # GET /Embeddable/section/1.xml
  def show
    @diy_section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :diy_section => @diy_section }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/section" } # section.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @diy_section , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @diy_section, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @diy_section, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @diy_section }
      end
    end
  end

  # GET /Embeddable/section/1/print
  def print
    @diy_section = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @diy_section }
    end
  end

  # GET /Embeddable/section/new
  # GET /Embeddable/section/new.xml
  def new
    @diy_section = Embeddable::Diy::Section.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_section => @diy_section }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @diy_section }
      end
    end
  end

  # GET /Embeddable/section/1/edit
  def edit
    @diy_section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_section => @diy_section }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @diy_section }
      end
    end
  end

  # POST /Embeddable/sections
  # POST /Embeddable/section.xml
  def create
    @diy_section = Embeddable::Diy::Section.new(params[:embeddable_diy_section])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @diy_section.save
        render :partial => 'new', :locals => { :diy_section => @diy_section }
      else
        render :xml => @diy_section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_section.save
          flash[:notice] = 'Embeddable::Diy::Section.was successfully created.'
          format.html { redirect_to(@diy_section) }
          format.xml  { render :xml => @diy_section, :status => :created, :location => @diy_section }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @diy_section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/section/1
  # PUT /Embeddable/section/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @diy_section = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      if cancel || @diy_section.update_attributes(params[:embeddable_diy_section])
        render :partial => 'show', :locals => { :diy_section => @diy_section }
      else
        render :xml => @diy_section.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_section.update_attributes(params[:embeddable_diy_section])
          flash[:notice] = 'Embeddable::Diy::Section.was successfully updated.'
          format.html { redirect_to(@diy_section) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @diy_section.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/section/1
  # DELETE /Embeddable/section/1.xml
  def destroy
    @diy_section = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(section_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @diy_section.page_elements.each do |pe|
      pe.destroy
    end
    @diy_section.destroy    
  end
end

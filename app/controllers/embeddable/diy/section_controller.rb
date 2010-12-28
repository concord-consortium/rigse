class Embeddable::Diy::SectionsController < ApplicationController
  # GET /Embeddable/diy_sections
  # GET /Embeddable/diy_sections.xml
  #
  def index
    debugger
    @diy_sections = Embeddable::Diy::Section.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html { render :template => "diy/sections/index", :layout => nil }
      format.xml  { render :xml => @diy_sections }
    end
  end

  # GET /Embeddable/diy_sections/1
  # GET /Embeddable/diy_sections/1.xml
  def show
    @diy_sections = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :diy_sections => @diy_sections }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/diy_sections" } # diy_sections.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @diy_sections , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @diy_sections, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @diy_sections, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @diy_sections }
      end
    end
  end

  # GET /Embeddable/diy_sections/1/print
  def print
    @diy_sections = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/embeddable/print" }
      format.xml  { render :xml => @diy_sections }
    end
  end

  # GET /Embeddable/diy_sections/new
  # GET /Embeddable/diy_sections/new.xml
  def new
    @diy_sections = Embeddable::Diy::Section.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_sections => @diy_sections }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @diy_sections }
      end
    end
  end

  # GET /Embeddable/diy_sections/1/edit
  def edit
    @diy_sections = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :diy_sections => @diy_sections }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @diy_sections }
      end
    end
  end

  # POST /Embeddable/diy_sections
  # POST /Embeddable/diy_sections.xml
  def create
    @diy_sections = Embeddable::Diy::Section.new(params[:diy_sections])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @diy_sections.save
        render :partial => 'new', :locals => { :diy_sections => @diy_sections }
      else
        render :xml => @diy_sections.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_sections.save
          flash[:notice] = 'Embeddable::Diy::Section.was successfully created.'
          format.html { redirect_to(@diy_sections) }
          format.xml  { render :xml => @diy_sections, :status => :created, :location => @diy_sections }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @diy_sections.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/diy_sections/1
  # PUT /Embeddable/diy_sections/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @diy_sections = Embeddable::Diy::Section.find(params[:id])
    if request.xhr?
      if cancel || @diy_sections.update_attributes(params[:embeddable_diy_sections])
        render :partial => 'show', :locals => { :diy_sections => @diy_sections }
      else
        render :xml => @diy_sections.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @diy_sections.update_attributes(params[:embeddable_diy_sections])
          flash[:notice] = 'Embeddable::Diy::Section.was successfully updated.'
          format.html { redirect_to(@diy_sections) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @diy_sections.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/diy_sections/1
  # DELETE /Embeddable/diy_sections/1.xml
  def destroy
    @diy_sections = Embeddable::Diy::Section.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(diy_sections_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @diy_sections.page_elements.each do |pe|
      pe.destroy
    end
    @diy_sections.destroy    
  end
end

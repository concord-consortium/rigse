class Portal::StudentClazzesController < ApplicationController

  include RestrictedPortalController
  public
  
  # GET /portal_student_clazzes
  # GET /portal_student_clazzes.xml
  def index
    @portal_student_clazzes = Portal::StudentClazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_student_clazzes }
    end
  end

  # GET /portal_student_clazzes/1
  # GET /portal_student_clazzes/1.xml
  def show
    @portal_student_clazz = Portal::StudentClazz.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_student_clazz }
    end
  end

  # GET /portal_student_clazzes/new
  # GET /portal_student_clazzes/new.xml
  def new
    @portal_student_clazz = Portal::StudentClazz.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_student_clazz }
    end
  end

  # GET /portal_student_clazzes/1/edit
  def edit
    @portal_student_clazz = Portal::StudentClazz.find(params[:id])
  end

  # POST /portal_student_clazzes
  # POST /portal_student_clazzes.xml
  def create
    @portal_student_clazz = Portal::StudentClazz.new(params[:portal_student_clazz])

    respond_to do |format|
      if @portal_student_clazz.save
        flash[:notice] = 'Portal::StudentClazz was successfully created.'
        format.html { redirect_to(@portal_student_clazz) }
        format.xml  { render :xml => @portal_student_clazz, :status => :created, :location => @portal_student_clazz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_student_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_student_clazzes/1
  # PUT /portal_student_clazzes/1.xml
  def update
    @portal_student_clazz = Portal::StudentClazz.find(params[:id])

    respond_to do |format|
      if @portal_student_clazz.update_attributes(params[:portal_student_clazz])
        flash[:notice] = 'Portal::StudentClazz was successfully updated.'
        format.html { redirect_to(@portal_student_clazz) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_student_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_student_clazzes/1
  # DELETE /portal_student_clazzes/1.xml
  def destroy
    @portal_student_clazz = Portal::StudentClazz.find(params[:id])
    @dom_id = @template.dom_id_for(@portal_student_clazz)
    @clazz = @portal_student_clazz.clazz
    @portal_student_clazz.destroy
    @clazz.reload
    respond_to do |format|
      format.html { redirect_to(portal_student_clazzes_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end

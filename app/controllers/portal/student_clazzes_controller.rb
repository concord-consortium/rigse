class Portal::StudentClazzesController < ApplicationController
  # GET /portal_student_clazzes
  # GET /portal_student_clazzes.xml
  def index
    @student_clazzes = Portal::StudentClazz.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @student_clazzes }
    end
  end

  # GET /portal_student_clazzes/1
  # GET /portal_student_clazzes/1.xml
  def show
    @student_clazz = Portal::StudentClazz.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @student_clazz }
    end
  end

  # GET /portal_student_clazzes/new
  # GET /portal_student_clazzes/new.xml
  def new
    @student_clazz = Portal::StudentClazz.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @student_clazz }
    end
  end

  # GET /portal_student_clazzes/1/edit
  def edit
    @student_clazz = Portal::StudentClazz.find(params[:id])
  end

  # POST /portal_student_clazzes
  # POST /portal_student_clazzes.xml
  def create
    @student_clazz = Portal::StudentClazz.new(params[:student_clazz])

    respond_to do |format|
      if @student_clazz.save
        flash[:notice] = 'Portal::StudentClazz was successfully created.'
        format.html { redirect_to(@student_clazz) }
        format.xml  { render :xml => @student_clazz, :status => :created, :location => @student_clazz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @student_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_student_clazzes/1
  # PUT /portal_student_clazzes/1.xml
  def update
    @student_clazz = Portal::StudentClazz.find(params[:id])

    respond_to do |format|
      if @student_clazz.update_attributes(params[:student_clazz])
        flash[:notice] = 'Portal::StudentClazz was successfully updated.'
        format.html { redirect_to(@student_clazz) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @student_clazz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_student_clazzes/1
  # DELETE /portal_student_clazzes/1.xml
  def destroy
    @student_clazz = Portal::StudentClazz.find(params[:id])
    @student_clazz.destroy

    respond_to do |format|
      format.html { redirect_to(portal_student_clazzes_url) }
      format.xml  { head :ok }
    end
  end
end

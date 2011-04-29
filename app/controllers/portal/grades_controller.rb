class Portal::GradesController < ApplicationController

  include RestrictedPortalController
  before_filter :admin_only
  public
  

  # GET /portal_grades
  # GET /portal_grades.xml
  def index
    @portal_grades = Portal::Grade.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_grades }
    end
  end

  # GET /portal_grades/1
  # GET /portal_grades/1.xml
  def show
    @portal_grade = Portal::Grade.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_grade }
    end
  end

  # GET /portal_grades/new
  # GET /portal_grades/new.xml
  def new
    @portal_grade = Portal::Grade.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_grade }
    end
  end

  # GET /portal_grades/1/edit
  def edit
    @portal_grade = Portal::Grade.find(params[:id])
  end

  # POST /portal_grades
  # POST /portal_grades.xml
  def create
    @portal_grade = Portal::Grade.new(params[:portal_grade])

    respond_to do |format|
      if @portal_grade.save
        flash[:notice] = 'Grade was successfully created.'
        format.html { redirect_to(@portal_grade) }
        format.xml  { render :xml => @portal_grade, :status => :created, :location => @portal_grade }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_grade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_grades/1
  # PUT /portal_grades/1.xml
  def update
    @portal_grade = Portal::Grade.find(params[:id])

    respond_to do |format|
      if @portal_grade.update_attributes(params[:portal_grade])
        flash[:notice] = 'Grade was successfully updated.'
        format.html { redirect_to(@portal_grade) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_grade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_grades/1
  # DELETE /portal_grades/1.xml
  def destroy
    @portal_grade = Portal::Grade.find(params[:id])
    @portal_grade.destroy

    respond_to do |format|
      format.html { redirect_to(portal_grades_url) }
      format.xml  { head :ok }
    end
  end
end

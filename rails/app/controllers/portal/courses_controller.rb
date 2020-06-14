class Portal::CoursesController < ApplicationController
  
  # TODO:  There need to be a lot more 
  # controller filters here...
  # this only protects management actions:
  include RestrictedPortalController
  
  
  public 
  # GET /portal_courses
  # GET /portal_courses.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Course
    @courses = Portal::Course.all
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @courses = policy_scope(Portal::Course)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # GET /portal_courses/1
  # GET /portal_courses/1.xml
  def show
    @course = Portal::Course.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @course

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /portal_courses/new
  # GET /portal_courses/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Course
    @course = Portal::Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /portal_courses/1/edit
  def edit
    @course = Portal::Course.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @course
  end

  # POST /portal_courses
  # POST /portal_courses.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Course
    @course = Portal::Course.new(params[:portal_course])

    respond_to do |format|
      if @course.save
        flash[:notice] = 'Portal::Course was successfully created.'
        format.html { redirect_to(@course) }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_courses/1
  # PUT /portal_courses/1.xml
  def update
    @course = Portal::Course.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @course

    respond_to do |format|
      if @course.update_attributes(params[:portal_course])
        flash[:notice] = 'Portal::Course was successfully updated.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_courses/1
  # DELETE /portal_courses/1.xml
  def destroy
    @course = Portal::Course.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @course
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(portal_courses_url) }
      format.xml  { head :ok }
    end
  end
end

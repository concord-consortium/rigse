class Portal::SubjectsController < ApplicationController
  
  include RestrictedPortalController
  public
  
  # GET /portal_subjects
  # GET /portal_subjects.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Portal::Subject
    @subjects = Portal::Subject.all
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @subjects = policy_scope(Portal::Subject)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }
    end
  end

  # GET /portal_subjects/1
  # GET /portal_subjects/1.xml
  def show
    @subject = Portal::Subject.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @subject

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /portal_subjects/new
  # GET /portal_subjects/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Portal::Subject
    @subject = Portal::Subject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /portal_subjects/1/edit
  def edit
    @subject = Portal::Subject.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @subject
  end

  # POST /portal_subjects
  # POST /portal_subjects.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Portal::Subject
    @subject = Portal::Subject.new(params[:subject])

    respond_to do |format|
      if @subject.save
        flash[:notice] = 'Portal::Subject was successfully created.'
        format.html { redirect_to(@subject) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_subjects/1
  # PUT /portal_subjects/1.xml
  def update
    @subject = Portal::Subject.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @subject

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = 'Portal::Subject was successfully updated.'
        format.html { redirect_to(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_subjects/1
  # DELETE /portal_subjects/1.xml
  def destroy
    @subject = Portal::Subject.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @subject
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(portal_subjects_url) }
      format.xml  { head :ok }
    end
  end
end

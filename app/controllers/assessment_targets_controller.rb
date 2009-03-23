class AssessmentTargetsController < ApplicationController
  # GET /assessment_targets
  # GET /assessment_targets.xml
  def index
    @assessment_targets = AssessmentTarget.search(params[:search], params[:page], self.current_user)
    # :include => [:expectations => [:expectation_indicators, :stem]]
    @search_string = params[:search]
    @paginated_objects = @assessment_targets

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assessment_targets }
    end
  end

  # GET /assessment_targets/1
  # GET /assessment_targets/1.xml
  def show
    @assessment_target = AssessmentTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assessment_target }
    end
  end

  # GET /assessment_targets/new
  # GET /assessment_targets/new.xml
  def new
    @assessment_target = AssessmentTarget.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assessment_target }
    end
  end

  # GET /assessment_targets/1/edit
  def edit
    @assessment_target = AssessmentTarget.find(params[:id])
  end

  # POST /assessment_targets
  # POST /assessment_targets.xml
  def create
    @assessment_target = AssessmentTarget.new(params[:assessment_target])

    respond_to do |format|
      if @assessment_target.save
        flash[:notice] = 'AssessmentTarget was successfully created.'
        format.html { redirect_to(@assessment_target) }
        format.xml  { render :xml => @assessment_target, :status => :created, :location => @assessment_target }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assessment_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assessment_targets/1
  # PUT /assessment_targets/1.xml
  def update
    @assessment_target = AssessmentTarget.find(params[:id])

    respond_to do |format|
      if @assessment_target.update_attributes(params[:assessment_target])
        flash[:notice] = 'AssessmentTarget was successfully updated.'
        format.html { redirect_to(@assessment_target) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assessment_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assessment_targets/1
  # DELETE /assessment_targets/1.xml
  def destroy
    @assessment_target = AssessmentTarget.find(params[:id])
    @assessment_target.destroy

    respond_to do |format|
      format.html { redirect_to(assessment_targets_url) }
      format.xml  { head :ok }
    end
  end
end

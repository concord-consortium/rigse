class RiGse::AssessmentTargetsController < ApplicationController
  # GET /RiGse/assessment_targets
  # GET /RiGse/assessment_targets.xml
  def index
    # :include => [:expectations => [:expectation_indicators, :stem]]
    @search_string = params[:search]

    respond_to do |format|
      format.html do
        @assessment_targets = RiGse::AssessmentTarget.search(params[:search], params[:page], nil)
      end
      format.xml  do
        @assessment_targets = RiGse::AssessmentTarget.find(:all)
        render :xml => @assessment_targets
      end
    end
  end

  # GET /RiGse/assessment_targets/1
  # GET /RiGse/assessment_targets/1.xml
  def show
    @assessment_target = RiGse::AssessmentTarget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assessment_target }
    end
  end

  # GET /RiGse/assessment_targets/new
  # GET /RiGse/assessment_targets/new.xml
  def new
    @assessment_target = RiGse::AssessmentTarget.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assessment_target }
    end
  end

  # GET /RiGse/assessment_targets/1/edit
  def edit
    @assessment_target = RiGse::AssessmentTarget.find(params[:id])
  end

  # POST /RiGse/assessment_targets
  # POST /RiGse/assessment_targets.xml
  def create
    @assessment_target = RiGse::AssessmentTarget.new(params[:assessment_target])

    respond_to do |format|
      if @assessment_target.save
        flash[:notice] = 'RiGse::AssessmentTarget.was successfully created.'
        format.html { redirect_to(@assessment_target) }
        format.xml  { render :xml => @assessment_target, :status => :created, :location => @assessment_target }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assessment_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/assessment_targets/1
  # PUT /RiGse/assessment_targets/1.xml
  def update
    @assessment_target = RiGse::AssessmentTarget.find(params[:id])

    respond_to do |format|
      if @assessment_target.update_attributes(params[:assessment_target])
        flash[:notice] = 'RiGse::AssessmentTarget.was successfully updated.'
        format.html { redirect_to(@assessment_target) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assessment_target.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/assessment_targets/1
  # DELETE /RiGse/assessment_targets/1.xml
  def destroy
    @assessment_target = RiGse::AssessmentTarget.find(params[:id])
    @assessment_target.destroy

    respond_to do |format|
      format.html { redirect_to(assessment_targets_url) }
      format.xml  { head :ok }
    end
  end
end

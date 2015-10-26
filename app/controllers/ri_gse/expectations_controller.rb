class RiGse::ExpectationsController < ApplicationController
  # GET /RiGse/expectations
  # GET /RiGse/expectations.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize RiGse::Expectation
    @expectations = RiGse::Expectation.all
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @expectations = policy_scope(RiGse::Expectation)
    respond_to do |format|
      format.html 
      format.xml { render :xml => @expectations }
    end
  end

  # GET /RiGse/expectations/1
  # GET /RiGse/expectations/1.xml
  def show
    @expectation = RiGse::Expectation.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @expectation

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expectation }
    end
  end

  # GET /RiGse/expectations/new
  # GET /RiGse/expectations/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize RiGse::Expectation
    @expectation = RiGse::Expectation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expectation }
    end
  end

  # GET /RiGse/expectations/1/edit
  def edit
    @expectation = RiGse::Expectation.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @expectation
  end

  # POST /RiGse/expectations
  # POST /RiGse/expectations.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize RiGse::Expectation
    @expectation = RiGse::Expectation.new(params[:expectation])

    respond_to do |format|
      if @expectation.save
        flash[:notice] = 'RiGse::Expectation.was successfully created.'
        format.html { redirect_to(@expectation) }
        format.xml  { render :xml => @expectation, :status => :created, :location => @expectation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/expectations/1
  # PUT /RiGse/expectations/1.xml
  def update
    @expectation = RiGse::Expectation.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @expectation

    respond_to do |format|
      if @expectation.update_attributes(params[:expectation])
        flash[:notice] = 'RiGse::Expectation.was successfully updated.'
        format.html { redirect_to(@expectation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/expectations/1
  # DELETE /RiGse/expectations/1.xml
  def destroy
    @expectation = RiGse::Expectation.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @expectation
    @expectation.destroy

    respond_to do |format|
      format.html { redirect_to(expectations_url) }
      format.xml  { head :ok }
    end
  end
end

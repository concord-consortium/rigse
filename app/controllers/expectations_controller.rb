class ExpectationsController < ApplicationController
  # GET /expectations
  # GET /expectations.xml
  def index
    @expectations = Expectation.search(params[:search], params[:page], self.current_user, [{:expectations => [:expectation_indicators, :expectation_stem]}])
    # :include => [:expectations => [:expectation_indicators, :stem]]
    @search_string = params[:search]
    @paginated_objects = @expectations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expectations }
    end
  end

  # GET /expectations/1
  # GET /expectations/1.xml
  def show
    @expectation = Expectation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expectation }
    end
  end

  # GET /expectations/new
  # GET /expectations/new.xml
  def new
    @expectation = Expectation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expectation }
    end
  end

  # GET /expectations/1/edit
  def edit
    @expectation = Expectation.find(params[:id])
  end

  # POST /expectations
  # POST /expectations.xml
  def create
    @expectation = Expectation.new(params[:expectation])

    respond_to do |format|
      if @expectation.save
        flash[:notice] = 'Expectation was successfully created.'
        format.html { redirect_to(@expectation) }
        format.xml  { render :xml => @expectation, :status => :created, :location => @expectation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expectations/1
  # PUT /expectations/1.xml
  def update
    @expectation = Expectation.find(params[:id])

    respond_to do |format|
      if @expectation.update_attributes(params[:expectation])
        flash[:notice] = 'Expectation was successfully updated.'
        format.html { redirect_to(@expectation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expectations/1
  # DELETE /expectations/1.xml
  def destroy
    @expectation = Expectation.find(params[:id])
    @expectation.destroy

    respond_to do |format|
      format.html { redirect_to(expectations_url) }
      format.xml  { head :ok }
    end
  end
end

class ExpectationStemsController < ApplicationController
  # GET /expectation_stems
  # GET /expectation_stems.xml
  def index
    @expectation_stems = ExpectationStem.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expectation_stems }
    end
  end

  # GET /expectation_stems/1
  # GET /expectation_stems/1.xml
  def show
    @expectation_stem = ExpectationStem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expectation_stem }
    end
  end

  # GET /expectation_stems/new
  # GET /expectation_stems/new.xml
  def new
    @expectation_stem = ExpectationStem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expectation_stem }
    end
  end

  # GET /expectation_stems/1/edit
  def edit
    @expectation_stem = ExpectationStem.find(params[:id])
  end

  # POST /expectation_stems
  # POST /expectation_stems.xml
  def create
    @expectation_stem = ExpectationStem.new(params[:expectation_stem])

    respond_to do |format|
      if @expectation_stem.save
        flash[:notice] = 'ExpectationStem was successfully created.'
        format.html { redirect_to(@expectation_stem) }
        format.xml  { render :xml => @expectation_stem, :status => :created, :location => @expectation_stem }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expectation_stem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expectation_stems/1
  # PUT /expectation_stems/1.xml
  def update
    @expectation_stem = ExpectationStem.find(params[:id])

    respond_to do |format|
      if @expectation_stem.update_attributes(params[:expectation_stem])
        flash[:notice] = 'ExpectationStem was successfully updated.'
        format.html { redirect_to(@expectation_stem) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expectation_stem.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expectation_stems/1
  # DELETE /expectation_stems/1.xml
  def destroy
    @expectation_stem = ExpectationStem.find(params[:id])
    @expectation_stem.destroy

    respond_to do |format|
      format.html { redirect_to(expectation_stems_url) }
      format.xml  { head :ok }
    end
  end
end

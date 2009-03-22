class OpenResponsesController < ApplicationController
  # GET /open_responses
  # GET /open_responses.xml
  def index
    @open_responses = OpenResponse.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @open_responses }
    end
  end

  # GET /open_responses/1
  # GET /open_responses/1.xml
  def show
    @open_response = OpenResponse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @open_response }
    end
  end

  # GET /open_responses/new
  # GET /open_responses/new.xml
  def new
    @open_response = OpenResponse.new

    respond_to do |format|
      format.html { render :partial=>'open_response', :layout=>false }
      format.xml  { render :xml => @open_response }
    end
  end

  # GET /open_responses/1/edit
  def edit
    @open_response = OpenResponse.find(params[:id])
  end

  # POST /open_responses
  # POST /open_responses.xml
  def create
    @open_response = OpenResponse.new(params[:open_response])

    respond_to do |format|
      if @open_response.save
        flash[:notice] = 'OpenResponse was successfully created.'
        format.html { redirect_to(@open_response) }
        format.xml  { render :xml => @open_response, :status => :created, :location => @open_response }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @open_response.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /open_responses/1
  # PUT /open_responses/1.xml
  def update
    @open_response = OpenResponse.find(params[:id])

    respond_to do |format|
      if @open_response.update_attributes(params[:open_response])
        flash[:notice] = 'OpenResponse was successfully updated.'
        format.html { redirect_to(@open_response) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @open_response.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /open_responses/1
  # DELETE /open_responses/1.xml
  def destroy
    @open_response = OpenResponse.find(params[:id])
    @open_response.destroy

    respond_to do |format|
      format.html { redirect_to(open_responses_url) }
      format.xml  { head :ok }
    end
  end
end

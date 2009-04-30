class OpenResponsesController < ApplicationController
  # GET /open_responses
  # GET /open_responses.xml
  def index
    # @open_responses = OpenResponse.find(:all)
    # @paginated_objects = @open_responses

    @open_responses = OpenResponse.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @open_responses }
    end
  end

  # GET /open_responses/1
  # GET /open_responses/1.xml
  def show
    @open_response = OpenResponse.find(params[:id])
    if request.xhr?
      render :partial => 'open_response', :locals => { :open_response => @open_response }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @open_response }
      end
    end
  end

  # GET /open_responses/1/print
  def print
    @open_response = OpenResponse.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @open_response }
    end
  end

  # GET /open_responses/new
  # GET /open_responses/new.xml
  def new
    @open_response = OpenResponse.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :open_response => @open_response }
    else
      respond_to do |format|
        format.html { render :partial=>'open_response', :locals => { :open_response => @open_response }, :layout=>false }
        format.xml  { render :xml => @open_response }
      end
    end
  end

  # GET /open_responses/1/edit
  def edit
    @open_response = OpenResponse.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :open_response => @open_response }
    end
  end

  # POST /open_responses
  # POST /open_responses.xml
  def create
    @open_response = OpenResponse.new(params[:open_response])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @open_response.save
        render :partial => 'new', :locals => { :open_response => @open_response }
      else
        render :xml => @open_response.errors, :status => :unprocessable_entity
      end
    else

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
  end

  # PUT /open_responses/1
  # PUT /open_responses/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @open_response = OpenResponse.find(params[:id])
    if request.xhr?
      if cancel || @open_response.update_attributes(params[:open_response])
        render :partial => 'show', :locals => { :open_response => @open_response }
      else
        render :xml => @open_response.errors, :status => :unprocessable_entity
      end
    else
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
  end

  # DELETE /open_responses/1
  # DELETE /open_responses/1.xml
  def destroy
    @open_response = OpenResponse.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(open_responses_url) }
      format.xml  { head :ok }
      format.js
    end
    @open_response.destroy
    # TODO:  We should move this logic into the model!
    @open_response.page_elements.each do |pe|
      pe.destroy
    end

  end
  
  
end

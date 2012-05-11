class Embeddable::OpenResponsesController < ApplicationController
  # GET /Embeddable/open_responses
  # GET /Embeddable/open_responses.xml
  def index
    # @open_responses = Embeddable::OpenResponse.all
    # @paginated_objects = @open_responses

    @open_responses = Embeddable::OpenResponse.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @open_responses }
    end
  end

  # GET /Embeddable/open_responses/1
  # GET /Embeddable/open_responses/1.xml
  def show
    @open_response = Embeddable::OpenResponse.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :open_response => @open_response }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/open_response" } # open_response.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @open_response  } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @open_response, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @open_response} }
        format.xml  { render :xml => @open_response }
      end
    end
  end

  # GET /Embeddable/open_responses/new
  # GET /Embeddable/open_responses/new.xml
  def new
    @open_response = Embeddable::OpenResponse.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :open_response => @open_response }
    else
      respond_to do |format|
        format.html { render :partial=>'open_response', :locals => { :open_response => @open_response }, :layout=>false }
        format.xml  { render :xml => @open_response }
      end
    end
  end

  # GET /Embeddable/open_responses/1/edit
  def edit
    @open_response = Embeddable::OpenResponse.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :open_response => @open_response }
    end
  end

  # POST /Embeddable/open_responses
  # POST /Embeddable/open_responses.xml
  def create
    @open_response = Embeddable::OpenResponse.new(params[:open_response])
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
          flash[:notice] = 'Embeddable::OpenResponse.was successfully created.'
          format.html { redirect_to(@open_response) }
          format.xml  { render :xml => @open_response, :status => :created, :location => @open_response }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @open_response.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/open_responses/1
  # PUT /Embeddable/open_responses/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @open_response = Embeddable::OpenResponse.find(params[:id])
    if request.xhr?
      if cancel || @open_response.update_attributes(params[:embeddable_open_response])
        render :partial => 'show', :locals => { :open_response => @open_response }
      else
        render :xml => @open_response.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @open_response.update_attributes(params[:embeddable_open_response])
          flash[:notice] = 'Embeddable::OpenResponse.was successfully updated.'
          format.html { redirect_to(@open_response) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @open_response.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/open_responses/1
  # DELETE /Embeddable/open_responses/1.xml
  def destroy
    @open_response = Embeddable::OpenResponse.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(open_responses_url) }
      format.xml  { head :ok }
      format.js
    end
    # TODO:  We should move this logic into the model!
    @open_response.page_elements.each do |pe|
      pe.destroy
    end
    @open_response.destroy

  end
  
  
end

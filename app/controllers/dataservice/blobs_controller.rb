class Dataservice::BlobsController < ApplicationController
  
  before_filter :admin_only, :except => [:show]
  
  protected
  
  def login_redirect
    flash[:notice] = "Please log in as an administrator" 
    redirect_to(:home)
  end
  
  def admin_only 
    unless is_admin?
      login_redirect
    end
  end
  
  def is_admin?
    return (current_user != nil && current_user.has_role?('admin'))
  end
  
  public
  
  # GET /dataservice_blobs
  # GET /dataservice_blobs.xml
  def index
    @dataservice_blobs = Dataservice::Blob.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_blobs }
    end
  end

  # GET /dataservice_blobs/1
  # GET /dataservice_blobs/1.xml
  def show
    @blob = Dataservice::Blob.find(params[:id])
    is_authorized = is_admin? || (@blob && @blob.token == params[:token])
    
    respond_to do |format|
      format.html {
        if is_authorized
          render
        else
          login_redirect
        end
      }
      format.xml  {
        if is_authorized
          render :xml => @blob
        else
          login_redirect
        end
      }
      format.blob  {
        if is_authorized
          type = params[:mimetype] ? params[:mimetype] : @blob.mimetype
          send_data(@blob.content, :type => type, :filename => "file", :disposition => 'inline' )
        else
          render :text => "<error>Forbidden</error>", :status => :forbidden  # Forbidden
        end
      }
    end
  end

  # GET /dataservice_blobs/new
  # GET /dataservice_blobs/new.xml
  def new
    @blob = Dataservice::Blob.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blob }
    end
  end

  # GET /dataservice_blobs/1/edit
  def edit
    @blob = Dataservice::Blob.find(params[:id])
  end

  # POST /dataservice_blobs
  # POST /dataservice_blobs.xml
  def create
    @blob = Dataservice::Blob.new(params[:blob])

    respond_to do |format|
      if @blob.save
        flash[:notice] = 'Dataservice::Blob was successfully created.'
        format.html { redirect_to(@blob) }
        format.xml  { render :xml => @blob, :status => :created, :location => @blob }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blob.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice_blobs/1
  # PUT /dataservice_blobs/1.xml
  def update
    @blob = Dataservice::Blob.find(params[:id])

    respond_to do |format|
      if @blob.update_attributes(params[:blob])
        flash[:notice] = 'Dataservice::Blob was successfully updated.'
        format.html { redirect_to(@blob) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blob.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice_blobs/1
  # DELETE /dataservice_blobs/1.xml
  def destroy
    @blob = Dataservice::Blob.find(params[:id])
    @blob.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_blobs_url) }
      format.xml  { head :ok }
    end
  end
end

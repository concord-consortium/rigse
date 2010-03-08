class Dataservice::BundleContentsController < ApplicationController
  
  # restrict access to admins or bundle formatted requests 
  include RestrictedBundleController
  public
  
  # GET /dataservice_bundle_contents
  # GET /dataservice_bundle_contents.xml
  def index
    @dataservice_bundle_contents = Dataservice::BundleContent.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dataservice_bundle_contents }
    end
  end

  # GET /dataservice_bundle_contents/1
  # GET /dataservice_bundle_contents/1.xml
  def show
    @dataservice_bundle_content = Dataservice::BundleContent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dataservice_bundle_content }
    end
  end

  # GET /dataservice_bundle_contents/new
  # GET /dataservice_bundle_contents/new.xml
  def new
    @dataservice_bundle_content = Dataservice::BundleContent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dataservice_bundle_content }
    end
  end

  # GET /dataservice_bundle_contents/1/edit
  def edit
    @dataservice_bundle_content = Dataservice::BundleContent.find(params[:id])
  end

  # POST /dataservice_bundle_contents
  # POST /dataservice_bundle_contents.xml
  def create
    @dataservice_bundle_content = Dataservice::BundleContent.new(params[:dataservice_bundle_content])

    respond_to do |format|
      if @dataservice_bundle_content.save
        flash[:notice] = 'Dataservice::BundleContent was successfully created.'
        format.html { redirect_to(@dataservice_bundle_content) }
        format.xml  { render :xml => @dataservice_bundle_content, :status => :created, :location => @dataservice_bundle_content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataservice_bundle_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dataservice_bundle_contents/1
  # PUT /dataservice_bundle_contents/1.xml
  def update
    @dataservice_bundle_content = Dataservice::BundleContent.find(params[:id])

    respond_to do |format|
      if @dataservice_bundle_content.update_attributes(params[:dataservice_bundle_content])
        flash[:notice] = 'Dataservice::BundleContent was successfully updated.'
        format.html { redirect_to(@dataservice_bundle_content) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataservice_bundle_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dataservice_bundle_contents/1
  # DELETE /dataservice_bundle_contents/1.xml
  def destroy
    @dataservice_bundle_content = Dataservice::BundleContent.find(params[:id])
    @dataservice_bundle_content.destroy

    respond_to do |format|
      format.html { redirect_to(dataservice_bundle_contents_url) }
      format.xml  { head :ok }
    end
  end
end

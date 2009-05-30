class MavenJnlp::VersionedJnlpUrlsController < ApplicationController
  # GET /maven_jnlp_versioned_jnlp_urls
  # GET /maven_jnlp_versioned_jnlp_urls.xml
  def index
    @maven_jnlp_versioned_jnlp_urls = MavenJnlp::VersionedJnlpUrl.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_versioned_jnlp_urls }
    end
  end

  # GET /maven_jnlp_versioned_jnlp_urls/1
  # GET /maven_jnlp_versioned_jnlp_urls/1.xml
  def show
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @versioned_jnlp_url }
    end
  end

  # GET /maven_jnlp_versioned_jnlp_urls/new
  # GET /maven_jnlp_versioned_jnlp_urls/new.xml
  def new
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @versioned_jnlp_url }
    end
  end

  # GET /maven_jnlp_versioned_jnlp_urls/1/edit
  def edit
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.find(params[:id])
  end

  # POST /maven_jnlp_versioned_jnlp_urls
  # POST /maven_jnlp_versioned_jnlp_urls.xml
  def create
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.new(params[:versioned_jnlp_url])

    respond_to do |format|
      if @versioned_jnlp_url.save
        flash[:notice] = 'MavenJnlp::VersionedJnlpUrl was successfully created.'
        format.html { redirect_to(@versioned_jnlp_url) }
        format.xml  { render :xml => @versioned_jnlp_url, :status => :created, :location => @versioned_jnlp_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @versioned_jnlp_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_versioned_jnlp_urls/1
  # PUT /maven_jnlp_versioned_jnlp_urls/1.xml
  def update
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.find(params[:id])

    respond_to do |format|
      if @versioned_jnlp_url.update_attributes(params[:versioned_jnlp_url])
        flash[:notice] = 'MavenJnlp::VersionedJnlpUrl was successfully updated.'
        format.html { redirect_to(@versioned_jnlp_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @versioned_jnlp_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_versioned_jnlp_urls/1
  # DELETE /maven_jnlp_versioned_jnlp_urls/1.xml
  def destroy
    @versioned_jnlp_url = MavenJnlp::VersionedJnlpUrl.find(params[:id])
    @versioned_jnlp_url.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_versioned_jnlp_urls_url) }
      format.xml  { head :ok }
    end
  end
end

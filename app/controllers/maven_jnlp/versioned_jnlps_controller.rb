class MavenJnlp::VersionedJnlpsController < ApplicationController
  # GET /maven_jnlp_versioned_jnlps
  # GET /maven_jnlp_versioned_jnlps.xml
  def index
    @maven_jnlp_versioned_jnlps = MavenJnlp::VersionedJnlp.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_versioned_jnlps }
    end
  end

  # GET /maven_jnlp_versioned_jnlps/1
  # GET /maven_jnlp_versioned_jnlps/1.xml
  def show
    @versioned_jnlp = MavenJnlp::VersionedJnlp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @versioned_jnlp }
    end
  end

  # GET /maven_jnlp_versioned_jnlps/new
  # GET /maven_jnlp_versioned_jnlps/new.xml
  def new
    @versioned_jnlp = MavenJnlp::VersionedJnlp.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @versioned_jnlp }
    end
  end

  # GET /maven_jnlp_versioned_jnlps/1/edit
  def edit
    @versioned_jnlp = MavenJnlp::VersionedJnlp.find(params[:id])
  end

  # POST /maven_jnlp_versioned_jnlps
  # POST /maven_jnlp_versioned_jnlps.xml
  def create
    @versioned_jnlp = MavenJnlp::VersionedJnlp.new(params[:versioned_jnlp])

    respond_to do |format|
      if @versioned_jnlp.save
        flash[:notice] = 'MavenJnlp::VersionedJnlp was successfully created.'
        format.html { redirect_to(@versioned_jnlp) }
        format.xml  { render :xml => @versioned_jnlp, :status => :created, :location => @versioned_jnlp }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @versioned_jnlp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_versioned_jnlps/1
  # PUT /maven_jnlp_versioned_jnlps/1.xml
  def update
    @versioned_jnlp = MavenJnlp::VersionedJnlp.find(params[:id])

    respond_to do |format|
      if @versioned_jnlp.update_attributes(params[:versioned_jnlp])
        flash[:notice] = 'MavenJnlp::VersionedJnlp was successfully updated.'
        format.html { redirect_to(@versioned_jnlp) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @versioned_jnlp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_versioned_jnlps/1
  # DELETE /maven_jnlp_versioned_jnlps/1.xml
  def destroy
    @versioned_jnlp = MavenJnlp::VersionedJnlp.find(params[:id])
    @versioned_jnlp.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_versioned_jnlps_url) }
      format.xml  { head :ok }
    end
  end
end

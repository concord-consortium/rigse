class MavenJnlp::MavenJnlpFamiliesController < ApplicationController
  # GET /maven_jnlp_maven_jnlp_families
  # GET /maven_jnlp_maven_jnlp_families.xml
  def index
    @maven_jnlp_maven_jnlp_families = MavenJnlp::MavenJnlpFamily.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_maven_jnlp_families }
    end
  end

  # GET /maven_jnlp_maven_jnlp_families/1
  # GET /maven_jnlp_maven_jnlp_families/1.xml
  def show
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @maven_jnlp_family }
    end
  end

  # GET /maven_jnlp_maven_jnlp_families/new
  # GET /maven_jnlp_maven_jnlp_families/new.xml
  def new
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @maven_jnlp_family }
    end
  end

  # GET /maven_jnlp_maven_jnlp_families/1/edit
  def edit
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.find(params[:id])
  end

  # POST /maven_jnlp_maven_jnlp_families
  # POST /maven_jnlp_maven_jnlp_families.xml
  def create
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.new(params[:maven_jnlp_family])

    respond_to do |format|
      if @maven_jnlp_family.save
        flash[:notice] = 'MavenJnlp::MavenJnlpFamily was successfully created.'
        format.html { redirect_to(@maven_jnlp_family) }
        format.xml  { render :xml => @maven_jnlp_family, :status => :created, :location => @maven_jnlp_family }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @maven_jnlp_family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_maven_jnlp_families/1
  # PUT /maven_jnlp_maven_jnlp_families/1.xml
  def update
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.find(params[:id])

    respond_to do |format|
      if @maven_jnlp_family.update_attributes(params[:maven_jnlp_family])
        flash[:notice] = 'MavenJnlp::MavenJnlpFamily was successfully updated.'
        format.html { redirect_to(@maven_jnlp_family) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @maven_jnlp_family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_maven_jnlp_families/1
  # DELETE /maven_jnlp_maven_jnlp_families/1.xml
  def destroy
    @maven_jnlp_family = MavenJnlp::MavenJnlpFamily.find(params[:id])
    @maven_jnlp_family.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_maven_jnlp_families_url) }
      format.xml  { head :ok }
    end
  end
end

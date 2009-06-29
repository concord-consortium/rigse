class MavenJnlp::JarsController < ApplicationController
  # GET /maven_jnlp_jars
  # GET /maven_jnlp_jars.xml
  def index
    @maven_jnlp_jars = MavenJnlp::Jar.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_jars }
    end
  end

  # GET /maven_jnlp_jars/1
  # GET /maven_jnlp_jars/1.xml
  def show
    @jar = MavenJnlp::Jar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @jar }
    end
  end

  # GET /maven_jnlp_jars/new
  # GET /maven_jnlp_jars/new.xml
  def new
    @jar = MavenJnlp::Jar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @jar }
    end
  end

  # GET /maven_jnlp_jars/1/edit
  def edit
    @jar = MavenJnlp::Jar.find(params[:id])
  end

  # POST /maven_jnlp_jars
  # POST /maven_jnlp_jars.xml
  def create
    @jar = MavenJnlp::Jar.new(params[:jar])

    respond_to do |format|
      if @jar.save
        flash[:notice] = 'MavenJnlp::Jar was successfully created.'
        format.html { redirect_to(@jar) }
        format.xml  { render :xml => @jar, :status => :created, :location => @jar }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @jar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_jars/1
  # PUT /maven_jnlp_jars/1.xml
  def update
    @jar = MavenJnlp::Jar.find(params[:id])

    respond_to do |format|
      if @jar.update_attributes(params[:jar])
        flash[:notice] = 'MavenJnlp::Jar was successfully updated.'
        format.html { redirect_to(@jar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @jar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_jars/1
  # DELETE /maven_jnlp_jars/1.xml
  def destroy
    @jar = MavenJnlp::Jar.find(params[:id])
    @jar.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_jars_url) }
      format.xml  { head :ok }
    end
  end
end

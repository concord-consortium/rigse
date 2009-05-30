class MavenJnlp::MavenJnlpServersController < ApplicationController
  # GET /maven_jnlp_maven_jnlp_servers
  # GET /maven_jnlp_maven_jnlp_servers.xml
  def index
    @maven_jnlp_maven_jnlp_servers = MavenJnlp::MavenJnlpServer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_maven_jnlp_servers }
    end
  end

  # GET /maven_jnlp_maven_jnlp_servers/1
  # GET /maven_jnlp_maven_jnlp_servers/1.xml
  def show
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @maven_jnlp_server }
    end
  end

  # GET /maven_jnlp_maven_jnlp_servers/new
  # GET /maven_jnlp_maven_jnlp_servers/new.xml
  def new
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @maven_jnlp_server }
    end
  end

  # GET /maven_jnlp_maven_jnlp_servers/1/edit
  def edit
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.find(params[:id])
  end

  # POST /maven_jnlp_maven_jnlp_servers
  # POST /maven_jnlp_maven_jnlp_servers.xml
  def create
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.new(params[:maven_jnlp_server])

    respond_to do |format|
      if @maven_jnlp_server.save
        flash[:notice] = 'MavenJnlp::MavenJnlpServer was successfully created.'
        format.html { redirect_to(@maven_jnlp_server) }
        format.xml  { render :xml => @maven_jnlp_server, :status => :created, :location => @maven_jnlp_server }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @maven_jnlp_server.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_maven_jnlp_servers/1
  # PUT /maven_jnlp_maven_jnlp_servers/1.xml
  def update
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.find(params[:id])

    respond_to do |format|
      if @maven_jnlp_server.update_attributes(params[:maven_jnlp_server])
        flash[:notice] = 'MavenJnlp::MavenJnlpServer was successfully updated.'
        format.html { redirect_to(@maven_jnlp_server) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @maven_jnlp_server.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_maven_jnlp_servers/1
  # DELETE /maven_jnlp_maven_jnlp_servers/1.xml
  def destroy
    @maven_jnlp_server = MavenJnlp::MavenJnlpServer.find(params[:id])
    @maven_jnlp_server.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_maven_jnlp_servers_url) }
      format.xml  { head :ok }
    end
  end
end

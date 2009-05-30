class MavenJnlp::IconsController < ApplicationController
  # GET /maven_jnlp_icons
  # GET /maven_jnlp_icons.xml
  def index
    @maven_jnlp_icons = MavenJnlp::Icon.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_icons }
    end
  end

  # GET /maven_jnlp_icons/1
  # GET /maven_jnlp_icons/1.xml
  def show
    @icon = MavenJnlp::Icon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @icon }
    end
  end

  # GET /maven_jnlp_icons/new
  # GET /maven_jnlp_icons/new.xml
  def new
    @icon = MavenJnlp::Icon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @icon }
    end
  end

  # GET /maven_jnlp_icons/1/edit
  def edit
    @icon = MavenJnlp::Icon.find(params[:id])
  end

  # POST /maven_jnlp_icons
  # POST /maven_jnlp_icons.xml
  def create
    @icon = MavenJnlp::Icon.new(params[:icon])

    respond_to do |format|
      if @icon.save
        flash[:notice] = 'MavenJnlp::Icon was successfully created.'
        format.html { redirect_to(@icon) }
        format.xml  { render :xml => @icon, :status => :created, :location => @icon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @icon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_icons/1
  # PUT /maven_jnlp_icons/1.xml
  def update
    @icon = MavenJnlp::Icon.find(params[:id])

    respond_to do |format|
      if @icon.update_attributes(params[:icon])
        flash[:notice] = 'MavenJnlp::Icon was successfully updated.'
        format.html { redirect_to(@icon) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @icon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_icons/1
  # DELETE /maven_jnlp_icons/1.xml
  def destroy
    @icon = MavenJnlp::Icon.find(params[:id])
    @icon.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_icons_url) }
      format.xml  { head :ok }
    end
  end
end

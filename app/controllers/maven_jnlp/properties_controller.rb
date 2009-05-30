class MavenJnlp::PropertiesController < ApplicationController
  # GET /maven_jnlp_properties
  # GET /maven_jnlp_properties.xml
  def index
    @maven_jnlp_properties = MavenJnlp::Property.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_properties }
    end
  end

  # GET /maven_jnlp_properties/1
  # GET /maven_jnlp_properties/1.xml
  def show
    @property = MavenJnlp::Property.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @property }
    end
  end

  # GET /maven_jnlp_properties/new
  # GET /maven_jnlp_properties/new.xml
  def new
    @property = MavenJnlp::Property.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @property }
    end
  end

  # GET /maven_jnlp_properties/1/edit
  def edit
    @property = MavenJnlp::Property.find(params[:id])
  end

  # POST /maven_jnlp_properties
  # POST /maven_jnlp_properties.xml
  def create
    @property = MavenJnlp::Property.new(params[:property])

    respond_to do |format|
      if @property.save
        flash[:notice] = 'MavenJnlp::Property was successfully created.'
        format.html { redirect_to(@property) }
        format.xml  { render :xml => @property, :status => :created, :location => @property }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_properties/1
  # PUT /maven_jnlp_properties/1.xml
  def update
    @property = MavenJnlp::Property.find(params[:id])

    respond_to do |format|
      if @property.update_attributes(params[:property])
        flash[:notice] = 'MavenJnlp::Property was successfully updated.'
        format.html { redirect_to(@property) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_properties/1
  # DELETE /maven_jnlp_properties/1.xml
  def destroy
    @property = MavenJnlp::Property.find(params[:id])
    @property.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_properties_url) }
      format.xml  { head :ok }
    end
  end
end

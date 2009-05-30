class MavenJnlp::NativeLibrariesController < ApplicationController
  # GET /maven_jnlp_native_libraries
  # GET /maven_jnlp_native_libraries.xml
  def index
    @maven_jnlp_native_libraries = MavenJnlp::NativeLibrary.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maven_jnlp_native_libraries }
    end
  end

  # GET /maven_jnlp_native_libraries/1
  # GET /maven_jnlp_native_libraries/1.xml
  def show
    @native_library = MavenJnlp::NativeLibrary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @native_library }
    end
  end

  # GET /maven_jnlp_native_libraries/new
  # GET /maven_jnlp_native_libraries/new.xml
  def new
    @native_library = MavenJnlp::NativeLibrary.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @native_library }
    end
  end

  # GET /maven_jnlp_native_libraries/1/edit
  def edit
    @native_library = MavenJnlp::NativeLibrary.find(params[:id])
  end

  # POST /maven_jnlp_native_libraries
  # POST /maven_jnlp_native_libraries.xml
  def create
    @native_library = MavenJnlp::NativeLibrary.new(params[:native_library])

    respond_to do |format|
      if @native_library.save
        flash[:notice] = 'MavenJnlp::NativeLibrary was successfully created.'
        format.html { redirect_to(@native_library) }
        format.xml  { render :xml => @native_library, :status => :created, :location => @native_library }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @native_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maven_jnlp_native_libraries/1
  # PUT /maven_jnlp_native_libraries/1.xml
  def update
    @native_library = MavenJnlp::NativeLibrary.find(params[:id])

    respond_to do |format|
      if @native_library.update_attributes(params[:native_library])
        flash[:notice] = 'MavenJnlp::NativeLibrary was successfully updated.'
        format.html { redirect_to(@native_library) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @native_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maven_jnlp_native_libraries/1
  # DELETE /maven_jnlp_native_libraries/1.xml
  def destroy
    @native_library = MavenJnlp::NativeLibrary.find(params[:id])
    @native_library.destroy

    respond_to do |format|
      format.html { redirect_to(maven_jnlp_native_libraries_url) }
      format.xml  { head :ok }
    end
  end
end

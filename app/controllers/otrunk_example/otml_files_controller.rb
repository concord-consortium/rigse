class OtrunkExample::OtmlFilesController < ApplicationController
  # GET /otrunk_example_otml_files
  # GET /otrunk_example_otml_files.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtmlFile
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @otml_files = policy_scope(OtrunkExample::OtmlFile)
    @otrunk_example_otml_files = OtrunkExample::OtmlFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @otrunk_example_otml_files }
    end
  end

  # GET /otrunk_example_otml_files/1
  # GET /otrunk_example_otml_files/1.xml
  def show
    @otml_file = OtrunkExample::OtmlFile.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otml_file

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @otml_file }
    end
  end

  # GET /otrunk_example_otml_files/new
  # GET /otrunk_example_otml_files/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtmlFile
    @otml_file = OtrunkExample::OtmlFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otml_file }
    end
  end

  # GET /otrunk_example_otml_files/1/edit
  def edit
    @otml_file = OtrunkExample::OtmlFile.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otml_file
  end

  # POST /otrunk_example_otml_files
  # POST /otrunk_example_otml_files.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtmlFile
    @otml_file = OtrunkExample::OtmlFile.new(params[:otml_file])

    respond_to do |format|
      if @otml_file.save
        flash[:notice] = 'OtrunkExample::OtmlFile was successfully created.'
        format.html { redirect_to(@otml_file) }
        format.xml  { render :xml => @otml_file, :status => :created, :location => @otml_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @otml_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /otrunk_example_otml_files/1
  # PUT /otrunk_example_otml_files/1.xml
  def update
    @otml_file = OtrunkExample::OtmlFile.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otml_file

    respond_to do |format|
      if @otml_file.update_attributes(params[:otml_file])
        flash[:notice] = 'OtrunkExample::OtmlFile was successfully updated.'
        format.html { redirect_to(@otml_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otml_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /otrunk_example_otml_files/1
  # DELETE /otrunk_example_otml_files/1.xml
  def destroy
    @otml_file = OtrunkExample::OtmlFile.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otml_file
    @otml_file.destroy

    respond_to do |format|
      format.html { redirect_to(otrunk_example_otml_files_url) }
      format.xml  { head :ok }
    end
  end
end

class OtrunkExample::OtrunkImportsController < ApplicationController
  # GET /otrunk_example_otrunk_imports
  # GET /otrunk_example_otrunk_imports.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtrunkImport
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @otrunk_imports = policy_scope(OtrunkExample::OtrunkImport)
    @otrunk_example_otrunk_imports = OtrunkExample::OtrunkImport.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @otrunk_example_otrunk_imports }
    end
  end

  # GET /otrunk_example_otrunk_imports/1
  # GET /otrunk_example_otrunk_imports/1.xml
  def show
    @otrunk_import = OtrunkExample::OtrunkImport.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otrunk_import

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @otrunk_import }
    end
  end

  # GET /otrunk_example_otrunk_imports/new
  # GET /otrunk_example_otrunk_imports/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtrunkImport
    @otrunk_import = OtrunkExample::OtrunkImport.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otrunk_import }
    end
  end

  # GET /otrunk_example_otrunk_imports/1/edit
  def edit
    @otrunk_import = OtrunkExample::OtrunkImport.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otrunk_import
  end

  # POST /otrunk_example_otrunk_imports
  # POST /otrunk_example_otrunk_imports.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize OtrunkExample::OtrunkImport
    @otrunk_import = OtrunkExample::OtrunkImport.new(params[:otrunk_import])

    respond_to do |format|
      if @otrunk_import.save
        flash[:notice] = 'OtrunkExample::OtrunkImport was successfully created.'
        format.html { redirect_to(@otrunk_import) }
        format.xml  { render :xml => @otrunk_import, :status => :created, :location => @otrunk_import }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @otrunk_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /otrunk_example_otrunk_imports/1
  # PUT /otrunk_example_otrunk_imports/1.xml
  def update
    @otrunk_import = OtrunkExample::OtrunkImport.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otrunk_import

    respond_to do |format|
      if @otrunk_import.update_attributes(params[:otrunk_import])
        flash[:notice] = 'OtrunkExample::OtrunkImport was successfully updated.'
        format.html { redirect_to(@otrunk_import) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otrunk_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /otrunk_example_otrunk_imports/1
  # DELETE /otrunk_example_otrunk_imports/1.xml
  def destroy
    @otrunk_import = OtrunkExample::OtrunkImport.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @otrunk_import
    @otrunk_import.destroy

    respond_to do |format|
      format.html { redirect_to(otrunk_example_otrunk_imports_url) }
      format.xml  { head :ok }
    end
  end
end

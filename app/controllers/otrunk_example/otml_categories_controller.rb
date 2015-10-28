class OtrunkExample::OtmlCategoriesController < ApplicationController
  # GET /otrunk_example_otml_categories
  # GET /otrunk_example_otml_categories.xml
  def index
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize OtrunkExample::OtmlCategory
    # PUNDIT_FIX_SCOPE_MOCKING
    # @otrunk_example_otml_categories = policy_scope(OtrunkExample::OtmlCategory)
    @otrunk_example_otml_categories = OtrunkExample::OtmlCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @otrunk_example_otml_categories }
    end
  end

  # GET /otrunk_example_otml_categories/1
  # GET /otrunk_example_otml_categories/1.xml
  def show
    @otml_category = OtrunkExample::OtmlCategory.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @otml_category

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @otml_category }
    end
  end

  # GET /otrunk_example_otml_categories/new
  # GET /otrunk_example_otml_categories/new.xml
  def new
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize OtrunkExample::OtmlCategory
    @otml_category = OtrunkExample::OtmlCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otml_category }
    end
  end

  # GET /otrunk_example_otml_categories/1/edit
  def edit
    @otml_category = OtrunkExample::OtmlCategory.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @otml_category
  end

  # POST /otrunk_example_otml_categories
  # POST /otrunk_example_otml_categories.xml
  def create
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize OtrunkExample::OtmlCategory
    @otml_category = OtrunkExample::OtmlCategory.new(params[:otml_category])

    respond_to do |format|
      if @otml_category.save
        flash[:notice] = 'OtrunkExample::OtmlCategory was successfully created.'
        format.html { redirect_to(@otml_category) }
        format.xml  { render :xml => @otml_category, :status => :created, :location => @otml_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @otml_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /otrunk_example_otml_categories/1
  # PUT /otrunk_example_otml_categories/1.xml
  def update
    @otml_category = OtrunkExample::OtmlCategory.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @otml_category

    respond_to do |format|
      if @otml_category.update_attributes(params[:otml_category])
        flash[:notice] = 'OtrunkExample::OtmlCategory was successfully updated.'
        format.html { redirect_to(@otml_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otml_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /otrunk_example_otml_categories/1
  # DELETE /otrunk_example_otml_categories/1.xml
  def destroy
    @otml_category = OtrunkExample::OtmlCategory.find(params[:id])
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @otml_category
    @otml_category.destroy

    respond_to do |format|
      format.html { redirect_to(otrunk_example_otml_categories_url) }
      format.xml  { head :ok }
    end
  end
end

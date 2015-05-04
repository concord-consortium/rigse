class MaterialsCollectionsController < ApplicationController
  include RestrictedController
  before_filter :admin_only

  # GET /materials_collections
  # GET /materials_collections.json
  def index
    @materials_collections = MaterialsCollection.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @materials_collections }
    end
  end

  # GET /materials_collections/1
  # GET /materials_collections/1.json
  def show
    @materials_collection = MaterialsCollection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/new
  # GET /materials_collections/new.json
  def new
    @materials_collection = MaterialsCollection.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/1/edit
  def edit
    @materials_collection = MaterialsCollection.find(params[:id])

    if request.xhr?
      render :partial => 'remote_form', :locals => { :materials_collection => @materials_collection }
    end
  end

  # POST /materials_collections
  # POST /materials_collections.json
  def create
    @materials_collection = MaterialsCollection.new(materials_collection_params)

    respond_to do |format|
      if @materials_collection.save
        format.html { redirect_to materials_collections_path, notice: 'Materials Collection was successfully created.' }
        format.json { render json: @materials_collection, status: :created, location: @materials_collection }
      else
        format.html { render action: "new" }
        format.json { render json: @materials_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /materials_collections/1
  # PATCH/PUT /materials_collections/1.json
  def update
    @materials_collection = MaterialsCollection.find(params[:id])

    if request.xhr?
      @materials_collection.update_attributes(materials_collection_params)
      render :partial => 'show', :locals => { :materials_collection => @materials_collection }
    else
      respond_to do |format|
        if @materials_collection.update_attributes(materials_collection_params)
          format.html { redirect_to @materials_collection, notice: 'Materials Collection was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @materials_collection.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /materials_collections/1
  # DELETE /materials_collections/1.json
  def destroy
    @materials_collection = MaterialsCollection.find(params[:id])
    @materials_collection.destroy

    if request.xhr?
      render :update do |page|
        page.replace_html "wrapper_materials_collection_#{params[:id]}", ""
      end
    else
      respond_to do |format|
        format.html { redirect_to materials_collections_url }
        format.json { head :no_content }
      end
    end
  end

  def sort_materials
    @materials_collection = MaterialsCollection.includes(:materials_collection_items).find(params[:id])
    paramlistname = view_context.dom_id_for(@materials_collection, :materials)
    @materials_collection.materials_collection_items.each do |material|
      material.position = params[paramlistname].index(material.id.to_s) + 1
      material.save
    end
    render :nothing => true
  end

  def remove_material
    item = MaterialsCollectionItem.where(id: params[:materials_collection_item_id], materials_collection_id: params[:id]).first
    if item && item.destroy
      render :nothing => true
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def materials_collection_params
      params.require(:materials_collection).permit(:description, :name)
    end
end

class MaterialsCollectionsController < ApplicationController
  include RestrictedController
  before_action :admin_only

  # GET /materials_collections
  # GET /materials_collections.json
  def index
    filtered = params[:project_id].to_s.length > 0 ? MaterialsCollection.where({project_id: params[:project_id]}) : MaterialsCollection
    @materials_collections = filtered.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @materials_collections }
    end
  end

  # GET /materials_collections/1
  # GET /materials_collections/1.json
  def show
    @materials_collection = MaterialsCollection.find(params[:id])
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/new
  # GET /materials_collections/new.json
  def new
    @materials_collection = MaterialsCollection.new
    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/1/edit
  def edit
    @materials_collection = MaterialsCollection.find(params[:id])
    # renders edit.html.haml
  end

  # POST /materials_collections
  # POST /materials_collections.json
  def create
    @materials_collection = MaterialsCollection.new(materials_collection_strong_params(params[:materials_collection]))

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
    respond_to do |format|
      if @materials_collection.update_attributes(materials_collection_strong_params(params[:materials_collection]))
        format.html { redirect_to @materials_collection, notice: 'Materials Collection was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @materials_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /materials_collections/1
  # DELETE /materials_collections/1.json
  def destroy
    @materials_collection = MaterialsCollection.find(params[:id])
    @materials_collection.destroy
    respond_to do |format|
      format.html { redirect_to materials_collections_url }
      format.json { head :no_content }
    end
  end

  def materials_collection_strong_params(params)
    params && params.permit(:description, :name, :project_id)
  end
end

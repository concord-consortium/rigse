class MaterialsCollectionsController < ApplicationController

  before_action :find_and_authorize_material_collection, only: ['show', 'edit', 'update', 'destroy']
  before_action :load_projects

  # GET /materials_collections
  # GET /materials_collections.json
  def index
    authorize MaterialsCollection
    search_scope = policy_scope(MaterialsCollection)
    search_scope = search_scope.where(project_id: params[:project_id]) if params[:project_id].to_s.length > 0
    @materials_collections = MaterialsCollection.search(params[:search], params[:page], nil, nil, search_scope)
    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @materials_collections }
    end
  end

  # GET /materials_collections/1
  # GET /materials_collections/1.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/new
  # GET /materials_collections/new.json
  def new
    authorize MaterialsCollection
    @materials_collection = MaterialsCollection.new
    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @materials_collection }
    end
  end

  # GET /materials_collections/1/edit
  def edit
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
    respond_to do |format|
      if @materials_collection.update(materials_collection_strong_params(params[:materials_collection]))
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
    @materials_collection.destroy
    respond_to do |format|
      format.html { redirect_to materials_collections_url }
      format.json { head :no_content }
    end
  end

  def materials_collection_strong_params(params)
    params && params.permit(:description, :name, :project_id)
  end

  private

  def find_and_authorize_material_collection
    @materials_collection = MaterialsCollection.find(params[:id])
    authorize @materials_collection
  end

  def load_projects
    @projects = policy_scope(Admin::Project)
  end

end

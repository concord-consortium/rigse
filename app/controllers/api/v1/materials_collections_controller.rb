class API::V1::MaterialsCollectionsController < API::APIController
  include React::DataHelpers

  # GET /api/v1/materials_collections/data?id=:id OR GET /api/v1/materials_collections/data?id[]=:id1&id[]=:id2
  # Supports multiple IDs provided. Always returns ARRAY of collections (even if only one ID is provided).
  # The main difference from regular MaterialsCollectionsController#show is that it also includes materials data.
  # It's intended to be used by client-side rendering code, so the ID is extracted out of path (more convenient).
  def data
    # Preserver order of collections provided by client!
    collection_by_id = MaterialsCollection.where(id: params[:id]).index_by { |mc| mc.id.to_s }
    ids = Array(params[:id])
    render json: ids.map { |id| materials_collection_data(collection_by_id[id]) }
  end

  private

  def materials_collection_data(materials_collection)
    {
        name: materials_collection.name,
        materials: materials_data(materials_collection.materials)
    }
  end
end

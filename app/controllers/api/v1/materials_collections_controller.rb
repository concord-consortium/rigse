class API::V1::MaterialsCollectionsController < API::APIController
  include React::DataHelpers

  # GET /api/v1/materials_collections/data?<params>id=:id OR GET /api/v1/materials_collections/data?id[]=:id1&id[]=:id2
  # Always returns ARRAY of collections (even if single collection is returned).
  # Supported params:
  #   - ?id=:id or ?id[]=:id1&id[]=:id2 - returns collections with given IDs
  #   - ?own_external_activities=true - returns 'fake' collection with own external activities
  #   - ?own_activities=true - returns 'fake' collection with own activities
  #   - ?own_investigations=true - returns 'fake' collection with own investigations
  #   - ?own_materials=true - returns 'fake' collection with own materials (sum of all categories above)
  def data
    collections = []
    collections += collections_by_ids(Array(params[:id])) if params[:id]
    collections += [own_materials]                        if params[:own_materials]
    collections += [own_external_activities]              if params[:own_external_activities]
    collections += [own_activities]                       if params[:own_activities]
    collections += [own_investigations]                   if params[:own_investigations]
    render json: collections
  end

  private

  def collections_by_ids(ids)
    return [] if ids.empty?
    # Preserver order of collections provided by client!
    collection_by_id = MaterialsCollection.where(id: params[:id]).index_by { |mc| mc.id.to_s }
    ids.map do |id|
      col = collection_by_id[id]
      materials_collection_data(col.name, col.materials)
    end
  end

  def own_materials
    materials_collection_data('My materials', current_visitor.materials)
  end

  def own_external_activities
    materials_collection_data('My materials', current_visitor.external_activities)
  end

  def own_activities
    materials_collection_data('My materials', current_visitor.activities)
  end

  def own_investigations
    materials_collection_data('My materials', current_visitor.investigations)
  end

  def materials_collection_data(name, materials)
    {
        name: name,
        materials: materials_data(materials)
    }
  end
end

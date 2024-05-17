class API::V1::MaterialsCollectionsController < API::APIController

  before_action :find_and_authorize_material_collection

  def sort_materials
    item_ids = params['item_ids']
    if !item_ids
      return error("Missing item_ids parameter")
    end

    items = item_ids.map { |i| MaterialsCollectionItem.find(i) }
    position = 1
    items.each do |item|
      if item.materials_collection_id == @materials_collection.id
        item.position = position
        position = position + 1
        item.save
      end
    end
    render_ok()
  end

  def remove_material
    item_id = params[:item_id]
    if !item_id
      return error("Missing item_id parameter")
    end

    item = MaterialsCollectionItem.where(id: item_id, materials_collection_id: @materials_collection.id).first
    if !item
      error("Invalid item id: #{item_id}")
    elsif !item.destroy
      error("Unable to delete item: #{item.id}")
    else
      render_ok
    end
  end

  private

  def render_ok
    render :json => { success: true }, :status => :ok
  end

  def find_and_authorize_material_collection
    @materials_collection = MaterialsCollection.find(params[:id])
    authorize @materials_collection
  end
end

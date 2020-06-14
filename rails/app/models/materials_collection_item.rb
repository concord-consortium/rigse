class MaterialsCollectionItem < ActiveRecord::Base
  attr_accessible :material_id, :material_type, :material, :materials_collection_id, :materials_collection, :position

  belongs_to :materials_collection
  belongs_to :material, polymorphic: true
end

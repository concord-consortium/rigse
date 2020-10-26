class MaterialsCollectionItem < ActiveRecord::Base
  belongs_to :materials_collection
  belongs_to :material, polymorphic: true
end

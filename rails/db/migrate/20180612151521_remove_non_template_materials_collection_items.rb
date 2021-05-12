class RemoveNonTemplateMaterialsCollectionItems < ActiveRecord::Migration[5.1]
  class MaterialsCollectionItem < ApplicationRecord
  end

  def up
    MaterialsCollectionItem.where("material_type <> 'ExternalActivity'").destroy_all
  end

  def down
  end
end

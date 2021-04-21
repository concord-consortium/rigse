class RemoveNonTemplateMaterialsCollectionItems < ActiveRecord::Migration
  class MaterialsCollectionItem < ApplicationRecord
  end

  def up
    MaterialsCollectionItem.where("material_type <> 'ExternalActivity'").destroy_all
  end

  def down
  end
end

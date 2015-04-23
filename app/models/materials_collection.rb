class MaterialsCollection < ActiveRecord::Base
  attr_accessible :description, :name, :project_id

  has_many :materials_collection_items
  has_many :materials, through: :materials_collection_items
end

class MaterialsCollection < ActiveRecord::Base
  attr_accessible :description, :name, :project_id

  has_many :materials_collection_items, order: :position

  # We can't do has_many :through on a polymorphic join, so emulate it...
  # has_many :materials, through: :materials_collection_items
  def materials
    # FIXME this will probably be slow with many materials...
    materials_collection_items.map {|mi| mi.material }
  end

  include Changeable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
end

class MaterialsCollection < ActiveRecord::Base
  attr_accessible :description, :name, :project_id

  has_many :materials_collection_items, dependent: :destroy, order: :position

  # List all supported material types in this array! It's used by #materials method.
  MATERIAL_TYPES = [Investigation, Activity, ExternalActivity]

  include Changeable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  # We can't do has_many :through on a polymorphic join, so emulate it...
  # materials_collection_items.map { |mi| mi.material } is simpler, but it
  # hits database N times.
  # Implementation below hits database only MATERIAL_TYPES.count times.
  def materials
    materials = materials_by_type
    materials_collection_items.map { |mi| materials[mi.material_type][mi.material_id] }
  end

  # This is slow, hits database N times.
  def materials_filtered_by_cohorts(allowed_cohorts)
    materials.select do |m|
      # Second part of the condition is intersection between two arrays.
      m.cohort_list.empty? || !(m.cohort_list & allowed_cohorts).empty?
    end
  end

  private

  def materials_by_type
    materials = {}
    MATERIAL_TYPES.each do |type|
      materials[type.to_s] = materials_of_type(type).index_by(&:id)
    end
    materials
  end

  def materials_of_type(type)
    type.joins(:materials_collection_items)
        .where(materials_collection_items: {materials_collection_id: id})
  end
end

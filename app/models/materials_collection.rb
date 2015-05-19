class MaterialsCollection < ActiveRecord::Base
  attr_accessible :description, :name, :project_id

  belongs_to :project, :class_name => "Admin::Project"

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
  # hits database N times. Implementation below hits database only MATERIAL_TYPES.count times.
  # If `allowed_cohorts` argument is provided, resulting list will be limited to materials that:
  #  - are assigned to one of the provided cohorts
  #  - are assigned to any cohort
  def materials(allowed_cohorts = nil)
    materials = materials_by_type(allowed_cohorts)
    # .compact removes nils if some materials were filtered out due to provided cohorts list.
    materials_collection_items.map { |mi| materials[mi.material_type][mi.material_id] }.compact
  end

  private

  def materials_by_type(allowed_cohorts)
    materials = {}
    MATERIAL_TYPES.each do |type|
       mat = materials_of_type(type)
       mat = mat.filtered_by_cohorts(allowed_cohorts) if allowed_cohorts
       materials[type.to_s] = mat.index_by(&:id)
    end
    materials
  end

  def materials_of_type(type)
    type.joins(:materials_collection_items)
        .where(materials_collection_items: {materials_collection_id: id})
  end
end

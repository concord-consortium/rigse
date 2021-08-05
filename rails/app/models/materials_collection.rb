class MaterialsCollection < ApplicationRecord
  belongs_to :project, :class_name => "Admin::Project"

  has_many :materials_collection_items, -> { order :position }, dependent: :destroy

  validates_presence_of :project

  # List all supported material types in this array! It's used by #materials method.
  MATERIAL_TYPES = [ExternalActivity]

  include Changeable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def fullname
    project ? "#{project.name}: #{name}" : name
  end

  # We can't do has_many :through on a polymorphic join, so emulate it...
  # materials_collection_items.map { |mi| mi.material } is simpler, but it
  # hits database N times. Implementation below hits database only MATERIAL_TYPES.count times.
  # If `allowed_cohorts` argument is provided, resulting list will be limited to materials that:
  #  - are assigned to one of the provided cohorts
  #  - are assigned to any cohort
  def materials(allowed_cohorts = nil, show_assessment_items = false)
    materials = materials_by_type(allowed_cohorts, show_assessment_items)
    # .compact removes nils if some materials were filtered out due to provided cohorts list.
    materials_collection_items.map { |mi| materials[mi.material_type][mi.material_id] }.compact
  end

  def has_materials(materials)
    items = materials_collection_items.map{|i| [i.material_type, i.material_id] }
    material_items = materials.map {|m| [m.class.to_s, m.id] }

    has_them_all = (material_items - items).empty? && (material_items & items).length == material_items.length
    return has_them_all
  end

  private

  def materials_by_type(allowed_cohorts, show_assessment_items)
    materials = {}
    MATERIAL_TYPES.each do |type|
       mat = materials_of_type(type)
       mat = mat.filtered_by_cohorts(allowed_cohorts) if allowed_cohorts
       mat = mat.where(is_assessment_item: false) unless show_assessment_items
       mat = mat.to_a
       mat.reject!{|m| m.archived? }
       materials[type.to_s] = mat.index_by(&:id)
    end
    materials
  end

  def materials_of_type(type)
    type.joins(:materials_collection_items)
        .where(materials_collection_items: {materials_collection_id: id})
  end
end

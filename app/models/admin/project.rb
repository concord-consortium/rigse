class Admin::Project < ActiveRecord::Base
  include Changeable

  self.table_name = 'admin_projects'

  self.extend SearchableModel
  @@searchable_attributes = %w{name}

  def self.searchable_attributes
    @@searchable_attributes
  end

  def self.all_sorted
    self.order("name ASC")
  end

  has_many :project_materials, dependent: :destroy
  has_many :activities, through: :project_materials, source: :material, source_type: 'Activity'
  has_many :investigations, through: :project_materials, source: :material, source_type: 'Investigation'
  has_many :external_activities, through: :project_materials, source: :material, source_type: 'ExternalActivity'
  has_many :interactives, through: :project_materials, source: :material, source_type: 'Interactive'
  has_many :materials_collections

  has_many :project_users, class_name: 'Admin::ProjectUser'
  has_many :users, :through => :project_users

  has_many :links, class_name: 'Admin::ProjectLink', :dependent => :destroy
  accepts_nested_attributes_for :links, :reject_if => lambda { |link| link[:name].blank? or link[:href].blank? }, :allow_destroy => true

  validates :name, presence: true
  validates :landing_page_slug, uniqueness: true, allow_nil: true
  validates :landing_page_slug, format: { with: /\A[a-z0-9\-]*\z/,
                                          message: "only allows lower case letters, digits and '-' character" }

  before_validation :nullify_empty_slug

  private

  # Empty strings comes from form, but we can't save it due to unique DB index.
  def nullify_empty_slug
    self.landing_page_slug = nil if landing_page_slug == ''
  end
end

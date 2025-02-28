class Image < ApplicationRecord
  attr_accessor :is_reprocessing

  belongs_to :user
  belongs_to :license,
             class_name: 'CommonsLicense',
             primary_key: 'code',
             foreign_key: 'license_code'

  has_one_attached :image

  validate :image_must_be_attached
  validates_presence_of :user_id, :name, :publication_status

  scope :published, -> { where(publication_status: 'published') }
  scope :private_status, -> { where(publication_status: 'private') }
  scope :draft_status, -> { where(publication_status: 'draft') }
  scope :by_user, ->(u) { where(user_id: u.id) }
  scope :with_status, ->(s) { where(publication_status: s) }
  scope :not_private, -> { where("#{table_name}.publication_status IN ('published', 'draft')") }

  scope :visible_to_user, ->(u) {
    where("#{table_name}.publication_status = 'published' OR
          (#{table_name}.publication_status = 'draft' AND #{table_name}.user_id = ?) OR
          (#{table_name}.publication_status = 'private' AND #{table_name}.user_id = ?)",
          u&.id, u&.id)
  }

  scope :visible_to_user_with_drafts, ->(u) {
    where("#{table_name}.publication_status IN ('published', 'draft') OR
          (#{table_name}.publication_status = 'private' AND #{table_name}.user_id = ?)", u&.id)
  }

  scope :no_drafts, -> { where("#{table_name}.publication_status NOT IN ('draft')") }

  scope :like, ->(name) {
    name = "%#{name}%"
    where("#{table_name}.name LIKE ? OR #{table_name}.attribution LIKE ?", name, name)
  }

  scope :ordered_by, ->(order) { order(order) }

  include Changeable
  include Publishable

  self.extend SearchableModel
  @@searchable_attributes = %w{name attribution}

  class << self
    def can_be_created_by?(user)
      user.has_role?('admin', 'manager', 'researcher', 'author') ||
      (Admin::Settings.default_settings.teachers_can_author? && user.portal_teacher)
    end

    def searchable_attributes
      @@searchable_attributes
    end

    def search_list(options)
      sortMapping  = {
        'Newest'       => "updated_at DESC",
        'Oldest'       => :updated_at,
        'Alphabetical' => :name,
      }

      name_matches = Image.like(options[:name])
      images = options[:only_current_users] ? name_matches.by_user(options[:user]) : name_matches.visible_to_user(options[:user])

      images = images.order(sortMapping[options[:sort_order]]) unless options[:sort_order].blank?
      images = images.paginate(page: options[:page] || 1, per_page: options[:per_page] || 20) if options[:paginate]

      images
    end
  end

  def display_name
    res = []
    res << "[#{publication_status.upcase}]" if %w(draft private).include?(publication_status)
    res << name
    res.join(" ")
  end

  def dimensions
    "#{width}x#{height}"
  end

  def image_size
    return 0 unless image.attached?

    begin
      image.blob.byte_size || 0
    rescue StandardError => e
      Rails.logger.warn("Unexpected error sizing image in models/image.rb: #{e}")
      0
    end
  end

  def image_must_be_attached
    errors.add(:image, "must be attached") unless image.attached?
  end
end

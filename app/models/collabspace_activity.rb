class CollabSpaceActivity
  include Virtus.model

  attribute :name, String
  attribute :url, String

  has_one :external_activity

  validates :name, presence: true
  validate :valid_url

  def valid_url
    begin
      validated_url = URI.parse(read_attribute(:url))
    rescue Exception
      validated_url = nil
    end
    errors.add(:url, 'must be a valid url') if validated_url.nil?
  end

  def has_external_activity
    !external_activity.nil?
  end

  def after_save
    if !has_external_activity
      self.external_activity = ExternalActivity.create(
        :name             => self.name,
        :url              => self.url
        :publication_status => "published",
        :user => current_user
      )
    end
  end

end

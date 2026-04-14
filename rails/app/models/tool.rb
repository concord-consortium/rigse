class Tool < ApplicationRecord
  has_many :external_activities, dependent: :nullify

  LAUNCH_METHODS = %w[oauth2].freeze

  before_validation { self.launch_method = launch_method.presence }
  validates :launch_method, inclusion: { in: LAUNCH_METHODS }, allow_nil: true

  def self.options_for_tool
    Tool.all.map { |t| [t.name, t.id] }
  end

end

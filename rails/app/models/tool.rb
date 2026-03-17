class Tool < ApplicationRecord
  has_many :external_activities, dependent: :nullify

  before_validation { self.launch_method = launch_method.presence }

  def self.options_for_tool
    Tool.all.map { |t| [t.name, t.id] }
  end

end

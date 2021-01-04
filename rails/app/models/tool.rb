class Tool < ActiveRecord::Base
  has_many :external_activities, dependent: :nullify

  def self.options_for_tool
    Tool.all.map { |t| [t.name, t.id] }
  end

end

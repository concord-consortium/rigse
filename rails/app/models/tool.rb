class Tool < ApplicationRecord
  has_many :external_activities, dependent: :nullify

  # validates :name, presence: { message: "Name can't be blank" }
  # validates :source_type, presence: { message: "Source type can't be blank" }
  # validates :tool_id, presence: { message: "Tool ID can't be blank" }

  def self.options_for_tool
    Tool.all.map { |t| [t.name, t.id] }
  end

end

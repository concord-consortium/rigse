class Tool < ActiveRecord::Base

  def self.options_for_tool
    Tool.all.map { |t| [t.name, t.id] }
  end

  attr_accessible :name, :source_type, :tool_id

end

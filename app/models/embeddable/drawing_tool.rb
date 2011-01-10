class Embeddable::DrawingTool < Embeddable::Embeddable
  set_table_name "embeddable_drawing_tools"

  
  @@searchable_attributes = %w{uuid name description background_image_url stamps}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Draw Tool"
  default_value_for :description, "description ..."

  send_update_events_to :investigations

  def self.display_name
    "Drawing Response"
  end
  
end

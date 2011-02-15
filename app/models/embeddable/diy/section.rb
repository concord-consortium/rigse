class Embeddable::Diy::Section < Embeddable::Embeddable
  set_table_name "embeddable_diy_sections"
    # t.integer user_id
    # t.string  uuid, 
    # t.string  name
    # t.text    description
    # t.boolean has_question
    # t.text    content
    # t.text    default_response
    # t.timestamps

  @@searchable_attributes = %w{name description content}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def self.display_name
    #self.name 
    "main content"
  end
  
end

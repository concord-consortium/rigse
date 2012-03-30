class Itsi::Model < Itsi::Itsi
  self.table_name = "itsidiy_models"
  
  # self.extend SearchableModel
  # 
  # @@searchable_attributes = %w{name description}
  # class <<self
  #   def searchable_attributes
  #     @@searchable_attributes
  #   end
  # end
  
  belongs_to :user, :class_name => "Itsi::User"
  has_many :activities, :class_name => "Itsi::Activity"
  belongs_to :model_type, :class_name => "Itsi::ModelType"

end

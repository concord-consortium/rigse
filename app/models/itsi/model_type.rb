class Itsi::ModelType < Itsi::Itsi
  self.table_name = "itsidiy_model_types"
  
  # self.extend SearchableModel
  # 
  # @@searchable_attributes = %w{name description}
  # class <<self
  #   def searchable_attributes
  #     @@searchable_attributes
  #   end
  # end

  belongs_to :user, :class_name => "Itsi::User"
  has_many :models, :class_name => "Itsi::Model"

end

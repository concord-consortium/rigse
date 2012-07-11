module ResponseTypes
  def self.saveable_types
    [ Saveable::OpenResponse, Saveable::MultipleChoice, Saveable::ImageQuestion ]
  end

  def saveable_types
  	ResponseTypes.saveable_types
  end

  def self.reportable_types
    [ Embeddable::OpenResponse, Embeddable::MultipleChoice, Embeddable::ImageQuestion ]
  end

  def reportable_types
  	ResponseTypes.reportable_types
  end
end
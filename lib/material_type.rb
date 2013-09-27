# For the purposes of searching and grouping items which appear similar to 
# end users but have different representations in the data model
module MaterialType
  def material_type
    return self.class.name.to_s
  end
end
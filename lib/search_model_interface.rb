# For the purposes of searching and grouping items which appear similar to
# end users but have different representations in the data model
module SearchModelInterface
  JNLPJavaRequirement  = "JNLPJavaRequirement"
  NoJavaRequirement    = "NoJavaRequirement"
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do
      acts_as_taggable_on :cohorts
    end
  end

  def material_type
    return self.class.name.to_s
  end

  # TODO: We intend to support icons for activities. Until that's a real attribute, have this stub method.
  def icon_image
    if self.respond_to? :thumbnail_url 
      return self.thumbnail_url
    end
    return nil
  end

  def offerings_by_clazz(clazz_ids)
    self.offerings.find(:clazz_id => clazz_ids)
  end

  def java_requirements
    case self
    when Investigation
      return JNLPJavaRequirement
    when Activity
      return JNLPJavaRequirement
    else
      return NoJavaRequirement
    end
  end
end
# encoding: UTF-8
# For the purposes of searching and grouping items which appear similar to
# end users but have different representations in the data model
module SearchModelInterface
  JNLPJavaRequirement  = "JNLPJavaRequirement"
  NoJavaRequirement    = "NoJavaRequirement"
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do
      acts_as_taggable_on :cohorts
      acts_as_taggable_on :grade_levels
      acts_as_taggable_on :subject_areas
    end
  end

  def material_type
    return self.class.name.to_s
  end

  # TODO: We intend to support icons for activities. Until that's a real attribute, have this stub method.
  def icon_image
    self.respond_to?(:thumbnail_url) && !self.thumbnail_url.blank? ? self.thumbnail_url : nil
  end

  def offerings_by_clazz(clazz_ids)
    self.offerings.find_all_by_clazz_id(clazz_ids)
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

  def description_abstract(length=255)
    if description.blank?
      ""
    else
      description.size > length+6 ? [description[0,length-6],description[-5,5]].join("…") : description
    end
  end

  def abstract_text
    return description_abstract unless self.respond_to?(:abstract)
    if abstract.blank?
      return description_abstract
    end
    return abstract
  end
end

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

      # Fast way to find all materials that are in `allowed_cohorts` OR they are not assigned to any cohort.
      scope :filtered_by_cohorts, ->(allowed_cohorts = []) do
        joins("LEFT OUTER JOIN taggings ON #{table_name}.id = taggings.taggable_id AND taggings.taggable_type = '#{name}' AND taggings.context = 'cohorts'")
          .joins("LEFT OUTER JOIN tags ON tags.id = taggings.tag_id")
          .where("tags.name IN (?) OR tags.name IS NULL", allowed_cohorts)
      end
    end
  end

  def material_type
    self.class.name.to_s
  end

  # TODO: We intend to support icons for activities. Until that's a real attribute, have this stub method.
  def icon_image
    respond_to?(:thumbnail_url) && !self.thumbnail_url.blank? ? self.thumbnail_url : nil
  end

  def offerings_by_clazz(clazz_ids)
    offerings.find_all_by_clazz_id(clazz_ids)
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
    return abstract if respond_to?(:abstract) && abstract.present?
    description_abstract
  end
end

# encoding: UTF-8
# For the purposes of searching and grouping items which appear similar to
# end users but have different representations in the data model
module SearchModelInterface
  RunsInBrowser  = "Runs in browser"
  RequiresDownload    = "Requires download"
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do
      acts_as_taggable_on :material_properties
      acts_as_taggable_on :grade_levels
      acts_as_taggable_on :subject_areas
      acts_as_taggable_on :sensors

      # Fast way to find all materials that are in `allowed_cohorts` OR they are not assigned to any cohort.
      def self.filtered_by_cohorts(allowed_cohorts = [])
        params = {}
        cohorts_where = allowed_cohorts.map.with_index do |cohort, i|
          params["name#{i}".intern] = cohort.name
          if cohort.project_id
            params["project_id#{i}".intern] = cohort.project_id
            "(admin_cohorts.name = :name#{i} AND admin_cohorts.project_id = :project_id#{i})"
          else
            "admin_cohorts.name = :name#{i}"
          end
        end
        joins("LEFT OUTER JOIN admin_cohort_items ON #{table_name}.id = admin_cohort_items.item_id AND admin_cohort_items.item_type = '#{name}'")
          .joins("LEFT OUTER JOIN admin_cohorts ON admin_cohorts.id = admin_cohort_items.admin_cohort_id")
          .where("#{cohorts_where.empty? ? "" : "(#{cohorts_where.join(' OR ')}) OR "} admin_cohort_items.id IS NULL", params)
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

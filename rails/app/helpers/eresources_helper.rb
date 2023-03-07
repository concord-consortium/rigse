module EresourcesHelper

  def eresources_edit_options_props(parentId, external_activity=@external_activity)

    return {
      parentId: parentId,

      editPublicationStatus: external_activity.respond_to?("publication_status") && policy(external_activity).edit_publication_status?,
      publicationStates: ExternalActivity.publication_states.map {|s| s.to_s},

      editGradeLevels: external_activity.respond_to?("grade_level_list") && policy(external_activity).edit_grade_levels?,
      allGradeLevels: Admin::Tag.where(scope: "grade_levels").map {|t| t.tag},

      editSubjectAreas: external_activity.respond_to?("subject_area_list") && policy(external_activity).edit_subject_areas?,
      allSubjectAreas: Admin::Tag.where(scope: "subject_areas").sort_by {|sub| sub[:tag].downcase}.map {|t| t.tag},

      editSensors: external_activity.respond_to?("sensor_list") && policy(external_activity).edit_sensors?,
      allSensors: Admin::Tag.where(scope: "sensors").map {|t| t.tag},

      editStandards: policy(external_activity).edit_standards?,  # PR REVIEW NOTE: the original code used `policy(object).admin_or_material_admin? || policy(object).author?` but I've used `admin_or_material_admin? || owner?` in the policy
      allStandards: StandardDocument.all.map {|s| {uri: s.uri, name: s.name} },

      eresource: {
        id: external_activity.id,
        type: external_activity.class.name.underscore,
        name: external_activity.name,
        publicationStatus: external_activity.publication_status,
        gradeLevels: external_activity.grade_level_list,
        subjectAreas: external_activity.subject_area_list,
        sensors: external_activity.sensor_list
      }
    }
  end

end

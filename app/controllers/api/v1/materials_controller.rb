class API::V1::MaterialsController < API::APIController
  include Materials::DataHelpers

  # GET /api/v1/materials/own
  # Template materials are not listed.
  def own
    # Filter out template objects.
    materials = current_visitor.external_activities +
                current_visitor.activities.is_template(false) +
                current_visitor.investigations.is_template(false)
    render json: materials_data(materials, params[:assigned_to_class])
  end

  # GET /api/v1/materials/featured
  def featured
    materials =
      Investigation.published.where(:is_featured => true).includes([:activities, :user]).to_a +
      ExternalActivity.published.where(:is_featured => true).includes([:template, :user]).to_a +
      Activity.investigation.published.where(:is_featured => true).includes(:investigation).to_a

    if params[:prioritize].present?
      prioritize = params[:prioritize].split(',').map { |p| p.to_i rescue 0 }
      type = params[:priority_type].presence || "investigation"
      typeKlass = case type.downcase
                    when "investigation", "sequence"
                      Investigation
                    when "activity"
                      Activity
                    when "external_activity"
                      ExternalActivity
                    else
                      Investigation
                  end

      first_up = materials.select { |m| m.is_a?(typeKlass) && prioritize.include?(m.id) }.sort_by { |a| prioritize.index(a.id) }
      the_rest = (materials - first_up).shuffle

      materials = first_up + the_rest
    else
      materials.shuffle!
    end

    render json: materials_data(materials, params[:assigned_to_class])
  end

  def assign_to_class
    # only add/delete if assign parameter exists to avoid deleting data on a bad request
    status = 200
    if params[:assign].present?
      portal_clazz = Portal::Clazz.find(params[:class_id])

      # allow only admins and the class teacher to assign
      allow = current_visitor.has_role?('admin') || portal_clazz.is_teacher?(current_visitor)

      if allow
        offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(portal_clazz.id, params[:material_type], params[:material_id])
        offering.position = portal_clazz.offerings.length
        offering.active = params[:assign].to_s == "1"
        offering.save
        prefix = "Updated assignment of"
      else
        prefix = "You are not allowed to assign/remove"
        status = 403 # unauthorized
      end
      message = "#{prefix} #{params[:material_type]} with id of #{params[:material_id]} in class #{portal_clazz.id}"
    else
      message = "Missing assign parameter"
      status = 400 # bad request
    end

    render json: {:message => message}, :status => status
  end
end

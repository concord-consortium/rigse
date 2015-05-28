class API::V1::MaterialsController < API::APIController
  include Materials::DataHelpers

  # GET /api/v1/materials/own
  # Template materials are not listed.
  def own
    # Filter out template objects.
    materials = current_visitor.external_activities +
                current_visitor.activities.is_template(false) +
                current_visitor.investigations.is_template(false)
    render json: materials_data(materials)
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
    
    render json: materials_data(materials)
  end
end

class API::V1::MaterialsBinController < API::APIController
  include Materials::DataHelpers

  # GET /api/v1/materials_bin/collections?id=:id OR GET /api/v1/materials_bin/collections?id[]=:id1&id[]=:id2
  # Always returns ARRAY of collections (even if single collection is returned).
  # Supported params:
  #   - ?id=:id or ?id[]=:id1&id[]=:id2 - returns collections with given IDs
  # Note that materials are filtered by cohorts of the current visitor!
  def collections
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Api::V1::MaterialsBin
    # authorize @materials_bin
    # authorize Api::V1::MaterialsBin, :new_or_create?
    # authorize @materials_bin, :update_edit_or_destroy?
    # Preserver order of collections provided by client!
    collection_by_id = MaterialsCollection.where(id: params[:id]).index_by { |mc| mc.id.to_s }
    collections = Array(params[:id]).map do |id|
      col = collection_by_id[id]
      materials_collection_data(col.name, col.materials(allowed_cohorts), params[:assigned_to_class])
    end
    render json: collections
  end

  # GET /api/v1/materials_bin/unofficial_materials?user_id=:user_id
  # Returns all unofficial materials authored by given user.
  # Note that materials are filtered by cohorts of the current visitor!
  def unofficial_materials
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Api::V1::MaterialsBin
    # authorize @materials_bin
    # authorize Api::V1::MaterialsBin, :new_or_create?
    # authorize @materials_bin, :update_edit_or_destroy?
    user_id = params[:user_id]
    # Note that activities and investigations are ALWAYS considered as official.
    # Only external activities can be unofficial at the moment.
    materials = ExternalActivity.filtered_by_cohorts(allowed_cohorts)
                                .where(user_id: user_id, is_official: false)
                                .order('name ASC')
    if current_user.nil? || (current_user.id != user_id.to_i && current_user.does_not_have_role?('admin'))
      materials.select!{|material|
        material.public?
      }
    end

    render json: materials_data(materials, params[:assigned_to_class])
  end

  # GET /api/v1/materials_bin/unofficial_materials_authors
  # Returns all authors of unofficial mateterials.
  def unofficial_materials_authors
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Api::V1::MaterialsBin
    # authorize @materials_bin
    # authorize Api::V1::MaterialsBin, :new_or_create?
    # authorize @materials_bin, :update_edit_or_destroy?
    # Note that activities and investigations are ALWAYS considered as official.
    # Only external activities can be unofficial at the moment.
    authors = ExternalActivity.filtered_by_cohorts(allowed_cohorts)
                              .where(is_official: false)
                              .group(:user_id)
                              .includes(:user)
                              .map { |e| {id: e.user.id, name: e.user.name} }
                              .sort_by { |u| u[:name] }
    render json: authors
  end

  private

  def allowed_cohorts
    # Empty array means that only materials that are not assigned to any cohorts will be displayed.
    current_visitor.portal_teacher ? current_visitor.portal_teacher.cohort_list : []
  end

  def materials_collection_data(name, materials, assigned_to_class)
    {
        name: name,
        materials: materials_data(materials, assigned_to_class)
    }
  end
end

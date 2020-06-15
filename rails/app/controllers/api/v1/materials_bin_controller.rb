class API::V1::MaterialsBinController < API::APIController
  include Materials::DataHelpers

  # GET /api/v1/materials_bin/collections?id=:id OR GET /api/v1/materials_bin/collections?id[]=:id1&id[]=:id2
  # Always returns ARRAY of collections (even if single collection is returned).
  # Supported params:
  #   - ?id=:id or ?id[]=:id1&id[]=:id2 - returns collections with given IDs
  # Note that materials are filtered by cohorts of the current visitor!
  def collections
    status = 200
    skip_lightbox_reloads = (params[:skip_lightbox_reloads] == true.to_s)

    # Preserver order of collections provided by client!
    collection_by_id = MaterialsCollection.where(id: params[:id]).index_by { |mc| mc.id.to_s }
    collections = Array(params[:id]).map do |id|
      col = collection_by_id[id]
      if col.nil?
        message = "Invalid collection ID #{id}."
        status  = 400 # bad request
        render json: {:message => message}, :status => status
        return
      end
      materials_collection_data(col.name, col.materials(allowed_cohorts, show_assessment_items), params[:assigned_to_class], 0, skip_lightbox_reloads)
    end
    render json: collections, :status => status
  end

  # GET /api/v1/materials_bin/unofficial_materials?user_id=:user_id
  # Returns all unofficial materials authored by given user.
  # Note that materials are filtered by cohorts of the current visitor!
  def unofficial_materials
    user_id = params[:user_id]
    # Note that activities and investigations are ALWAYS considered as official.
    # Only external activities can be unofficial at the moment.
    materials = ExternalActivity.filtered_by_cohorts(allowed_cohorts)
                                .where(user_id: user_id, is_official: false)
                                .order('name ASC')
    # Apply publication status and assessment item filters.
    materials = filtered_materials(materials, user_id)
    render json: materials_data(materials, params[:assigned_to_class])
  end

  # GET /api/v1/materials_bin/unofficial_materials_authors
  # Returns all authors of unofficial materials.
  def unofficial_materials_authors
    # Note that activities and investigations are ALWAYS considered as official.
    # Only external activities can be unofficial at the moment.
    materials = ExternalActivity.filtered_by_cohorts(allowed_cohorts)
                                .where(is_official: false)
                                .group(:user_id)
                                .includes(:user)
    # Apply publication status and assessment item filters.
    materials = filtered_materials(materials)
    authors = materials.map { |e| {id: e.user.id, name: e.user.name} }
                       .sort_by { |u| u[:name] }
    render json: authors
  end

  private

  def allowed_cohorts
    # Empty array means that only materials that are not assigned to any cohorts will be displayed.
    current_visitor.portal_teacher ? current_visitor.portal_teacher.cohorts : []
  end

  def show_assessment_items
    !!current_visitor.portal_teacher || current_visitor.has_role?('admin')
  end

  def filtered_materials(materials, user_id = -1)
    materials = materials.where(is_assessment_item: false) unless show_assessment_items
    materials = materials.where(is_archived: false)
    if current_user.nil? || (current_user.id != user_id.to_i && current_user.does_not_have_role?('admin'))
      materials = materials.where(publication_status: 'published')
    end
    materials
  end

  def materials_collection_data(name,
                                materials,
                                assigned_to_class,
                                include_related         = 0,
                                skip_lightbox_reloads   = false)
    {
        name: name,
        materials: materials_data(  materials,
                                    assigned_to_class,
                                    include_related,
                                    skip_lightbox_reloads )
    }
  end
end

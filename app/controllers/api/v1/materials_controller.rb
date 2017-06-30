class API::V1::MaterialsController < API::APIController
  include Materials::DataHelpers

  #
  # Map of class types supported material types.
  #
  # Might also consider using "classify" and "constantize" here
  # rather than a hard coded map of types. But that might require
  # additional input validation or otherwise constrain how we define
  # the http parameters.
  #
  @@supported_material_types = {
    "external_activity" => ExternalActivity,
    "interactive"       => Interactive
  }


  # GET /api/v1/materials/own
  # Template materials are not listed.
  def own
    # Filter out template objects.
    materials = current_visitor.external_activities +
                current_visitor.activities.is_template(false) +
                current_visitor.investigations.is_template(false)
    materials.reject! { |m| m.archived? }
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

  #
  # Get all available materials
  #
  def all

    materials = ExternalActivity.includes(:user, :template).all +
                Interactive.all

    render json: materials_data(materials)

  end

  #
  # Remove a favorite from the current user.
  #
  # Request params should contain:
  #
  # favorite_id     The favorite id
  #
  # POST /api/v1/materials/remove_favorite
  #
  def remove_favorite

    if !current_user || current_user.anonymous?
      render json: {:message => "Cannot remove favorite for non-logged in user."}, :status => 400
      return
    end

    favorite_id = params[:favorite_id]

    if favorite_id.nil?
      render json: {:message => "No favorite id specified."}, :status => 400
      return
    end

    favorite = nil

    begin
      favorite = Favorite.find(favorite_id)
    rescue ActiveRecord::RecordNotFound => rnf
      render json: {:message => "RecordNotFound Favorite #{favorite_id} does not exist."}, :status => 400
      return
    end

    if favorite.nil?
      render json: {:message => "Favorite #{favorite_id} does not exist."}, :status => 400
      return
    end

    if favorite.user != current_user
      render json: {:message => "Cannot delete favorite not owned by current user."}, :status => 400
      return
    end

    favorite.destroy
    message = "Favorite #{favorite_id} removed."

    render json: {  :message => "Favorite #{favorite_id} removed."},
                    :status => 200

  end

  #
  # Add a favorite to the current user.
  #
  # Request params should contain:
  #
  # id      The id of the material
  # type    The type of the material
  #
  # POST /api/v1/materials/add_favorite
  #
  def add_favorite

    if !current_user || current_user.anonymous?
      render json: {:message => "Cannot add favorite for non-logged in user."},
                    :status => 400
      return
    end

    favorite_id = -1
    type        = params[:material_type]
    id          = params[:id]

    if type.nil? || id.nil?
      render json: {:message => "Missing material type (#{type}) or id (#{id})"}, :status => 400
      return
    end

    item = nil

    begin

      #
      # Map of class types supported for favorites.
      #
      # Might also consider using "classify" and "constantize" here
      # rather than a hard coded map of types. But that might require
      # additional input validation or otherwise constrain how we define
      # the http parameters.
      #
      supported_types = {
            "external_activity" => ExternalActivity,
            "interactive"       => Interactive
      }

      rubyclass = supported_types[type]

      if rubyclass.nil?
        render json: {  :message => "Invalid material type #{type}"},
                        :status => 400
        return
      end

      item = rubyclass.find(id)

      if item.nil?
        render json: {:message => "Invalid material id #{id}"}, :status => 400
        return
      end

      favorite = current_user.favorites.create(favoritable: item)
      if favorite.id.nil?
        favorite = current_user.favorites.find_by_favoritable_id(item.id)
      end
      favorite_id = favorite.id

      render json: {  :message        => "Created favorite #{favorite_id}",
                      :favorite_id    => favorite_id  }, :status => 200

    rescue ActiveRecord::RecordNotFound => rnf
      render json: {:message => "RecordNotFound Invalid material id #{id}" },
                    :status => 400
    end

  end

  #
  # Get all favorites for the currently logged in user.
  #
  def get_favorites

    if !current_user || current_user.anonymous?
      render json: {:message => "Cannot retrieve favorites for non-logged in user."}, :status => 400
      return
    end

    favorites     = current_user.favorites
    type_ids_map  = {}
    materials     = []

    #
    # Build sets of IDs for each type
    #
    favorites.each do |favorite|
      favoritable_type    = favorite.favoritable_type
      favoritable_id      = favorite.favoritable_id
      if !type_ids_map[favoritable_type]
        type_ids_map[favoritable_type] = []
      end
      type_ids_map[favoritable_type].append(favoritable_id)
    end

    if type_ids_map['ExternalActivity']
      materials += ExternalActivity.includes(:template, :user, :subject_areas, :grade_levels).find(type_ids_map['ExternalActivity'])
    end

    if type_ids_map['Interactive']
      materials += Interactive.includes(:user, :subject_areas, :grade_levels).find(type_ids_map['Interactive'])
    end

    data = materials_data(materials)

    render json: data, :status => 200

  end

  #
  #
  # Get a single materials item and return a json representation
  # GET /api/v1/materials/:type/:id
  #
  def show

    type            = params[:material_type]
    id              = params[:id]
    include_related = params[:include_related]

    status          = 200
    data            = {}

    begin
      item = get_materials_item id, type
    rescue ActiveRecord::RecordNotFound => rnf
      render json: { :message => rnf.message}, :status => 400
      return
    end

    if item
      array = materials_data [item], nil, include_related

      if array.size == 1

        data = array[0]

      else
        status = 400
        data = {:message =>
                "Unexpected materials size #{array.size}"}
      end

    else
      status = 400
      data = {  :message =>
                "Cannot find materials item type (#{type}) with id (#{id})" }
    end

    render json: data, :status => status

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

  private

  #
  # Return a single material item.
  #
  # id      The item id. (An id of ExternalActivity, Investigation, etc)
  # type    A supported material type as a string key present in
  #         the @@supported_material_types map. This will map to a
  #         ruby class of the appropiate type, which will be returned
  #         and can be used by materials libs to convert into json
  #         and be consumed by API clients.
  #
  def get_materials_item(id, type)

    rubyclass = @@supported_material_types[type]

    if rubyclass

      includes = [  :user,
                    :projects,
                    :subject_areas,
                    :grade_levels   ]

      if rubyclass == ExternalActivity
        includes.push :template
      end

      item = rubyclass.includes(includes).find(id)

      if item
        return item
      end

    else
        raise ActiveRecord::RecordNotFound, "Invalid material type (#{type})"
    end

    raise ActiveRecord::RecordNotFound,
            "Cannot find material type (#{type}) with id (#{id})"
  end

end

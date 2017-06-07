class API::V1::MaterialsController < API::APIController
  include Materials::DataHelpers

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
  # GET /api/v1/materials/remove_favorite
  #
  def remove_favorite

    status  = 200
    message = "Removing favorite..."

    if current_visitor
      favorite_id = params[:favorite_id]

      if favorite_id
        
        favorite = nil

        begin
          favorite = Favorite.find(favorite_id)
        rescue ActiveRecord::RecordNotFound => rnf
          status = 400
          message = "RecordNotFound Favorite #{favorite_id} does not exist."
        end

        if favorite
          if favorite.user == current_visitor
            favorite.destroy
            # current_visitor.favorites.delete(favorite)
            message = "Favorite #{favorite_id} removed."
          else
            status = 400
            message = "Cannot delete favorite not owned by current user."
          end
        else
          status = 400
          message = "Favorite #{favorite_id} does not exist."
        end
      else
        status = 400
        message = "No favorite id specified."
      end
    else 
      status = 400
      message = "Cannot remove favorite for non-logged in user."
    end

    render json: {:message => message}, :status => status

  end

  #
  # Add a favorite to the current user.
  #
  # Request params should contain:
  #
  # id      The id of the material
  # type    The type of the material
  #
  # GET /api/v1/materials/add_favorite
  #
  def add_favorite

    status      = 200
    message     = "Adding favorite..."
    favorite_id = -1

    if current_visitor
    
      type  = params[:material_type]
      id    = params[:id]

      if type && id 

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

          if rubyclass 
            item = rubyclass.find(id)
          else
            status = 400
            message = "Invalid material type #{type}"
          end
        rescue ActiveRecord::RecordNotFound => rnf
          status = 400
          message = "RecordNotFound Invalid item #{id}"
        end

        if item
          #
          # Unclear if this should first check for the existence of 
          # the favorite. The unique index should ensure there is only
          # one favorite per user per item. When attempting to add 
          # a duplicate, rails logs:
          # Favorite Exists (1.0ms) SELECT 1 AS one FROM `favorites` ...
          # and no error is reported. This might be less expensive than
          # attempting to determine if the favorite exists otherwise.
          #
          favorite = Favorite.create(   user: current_visitor, 
                                        favoritable: item       )
          if favorite.id.nil?
            #
            # Query for the existing favorite so that we can 
            # return the ID to the client who presumably did not have it
            # prior to this call.
            #
            favorite = Favorite.where(  user_id: current_visitor.id, 
                                        favoritable_id: id,
                                        favoritable_type: rubyclass.name )[0]
            message = "Favorite already exists with id #{favorite.id}."
          else
            #
            # Add the new favorite for this user.
            #
            current_visitor.favorites.append( favorite )
            message = "Added new favorite with id #{favorite.id}."
          end
          favorite_id = favorite.id

        else 
          status = 400
          message = "Invalid item #{id}"
        end
      else
        status = 400
        message = "Missing type (#{type}) or id (#{id})"
      end
    else
      status = 400
      message = "Cannot add favorite for non-logged in user."
    end

    render json: {  :message        => message, 
                    :favorite_id    => favorite_id  }, :status => status

  end

  #
  # Get all favorites for the currently logged in user.
  #
  def get_favorites

    status  = 200
    data    = nil

    if current_user

      favorites     = current_visitor.favorites
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

      #
      # Now do a single query for each type
      #
      type_ids_map.each do |key, val| 
        items = key.constantize.find(val)   # E.g. this might become:
                                            # ExternalActivity.find([1,2,3])
        materials += items
      end

      data = materials_data(materials)

    else 
      status = 400
      data = {:message => "Cannot retrieve favorites for non-logged in user."}
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
end

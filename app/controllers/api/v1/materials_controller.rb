class API::V1::MaterialsController < API::APIController
  include Materials::DataHelpers

  #
  # Default number of related materials to return
  #
  @@DEFAULT_RELATED_MATERIALS_COUNT = 4

  #
  # Default base URL for ASN search
  #
  @@ASN_SEARCH_BASE_URL = "https://elastic1.asn.desire2learn.com/api/1/search?"

  #
  # Fields to return from ASN queries.
  #
  # These are fields required by process_asn_response()
  # You can specify your own desired return fields in your http query
  # but you will have to process that response yourself.
  #
  @@asn_return_fields = "identifier,"           <<
                        "is_part_of,"           <<
                        "is_child_of,"          <<
                        "type,"                 <<
                        "statement_notation,"   <<
                        "statement_label,"      <<
                        "description,"          <<
                        "list_id"


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

  #
  # Validate methods that require material type and id.
  #
  before_filter :validate_material, 
                :only => [  :get_materials_standards, 
                            :add_materials_standard,
                            :remove_materials_standard  ]

  #
  # Validate methods that require an ASN api key be configured.
  #
  before_filter :validate_asn_api_key, 
                :only => [  :get_standard_statements,
                            :add_materials_standard     ]

  #
  # Validate methods that mutate material standards, or
  # attempt to access the ASN API.
  #
  before_filter :validate_standards_permissions,
                :only => [  :get_standard_statements,
                            :add_materials_standard,
                            :remove_materials_standard  ]

  #
  # GET /api/v1/materials/own
  # Template materials are not listed.
  #
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

      rubyclass = @@supported_material_types[type]

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
    include_related = params.has_key?(:include_related)     ? 
                        params[:include_related].to_i       : 
                        @@DEFAULT_RELATED_MATERIALS_COUNT

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


  #
  # Get the standards associated with a material
  #
  # params[:material_type]  The material type
  # params[:material_id]    The material ID
  #
  def get_materials_standards

    uri     = params[:identifier]
    type    = params[:material_type]
    id      = params[:material_id]

    statements = 
        StandardStatement.find_all_by_material_type_and_material_id(
            type,
            id,
            :order => "uri ASC")

    ret = []

    statements.each do |statement|
   
        ret.push( {
            uri:                statement.uri,
            description:        statement.description,
            statement_label:    statement.statement_label,
            statement_notation: statement.statement_notation,
            doc:                statement.doc,
            is_applied:         true
        })

    end

    render json: {:statements => ret}, :status => 200
 
  end


  #
  # Add a standard to a material
  #
  # params[:identifier]     The standard statement identifier (URI)
  # params[:material_type]  The material type
  # params[:material_id]    The material ID
  #
  def add_materials_standard

    key     = ENV['ASN_API_KEY']
    uri     = params[:identifier]
    type    = params[:material_type]
    id      = params[:material_id]


    if !uri.present?
      render json: {:message => "No standard statement URI specified." },
                    :status => 400
      return
    end


	#
    # Before querying ASN, check if we already have this standard associated
    #
    existing = StandardStatement.find_by_uri_and_material_type_and_material_id(
                                                                        uri,
                                                                        type,
                                                                        id )
    if !existing.nil? 
      render json: {:message => "Standard #{uri} already exists for material type (#{type}) id (#{id})" },
                    :status => 200
      return
    end

    #
    # Build ASN query to return only the standard matching this 
    # uri identifier.
    #
    query_string = "identifier:'#{uri}'"

    query = {   "bq"            => query_string,
                "return-fields" => @@asn_return_fields,
                "key"           => "#{key}" }

    response = HTTParty.get(@@ASN_SEARCH_BASE_URL, :query => query)

    hits        = response['hits']['hit']
    statement   = process_asn_response(hits)[0]
  
    #
    # Find all parents. Walk up the tree until is_child_of is equal to
    # the uri of the document itself is_part_of
    #
    parents     = []
    doc_uri     = statement[:is_part_of]
    parent_uri  = statement[:is_child_of]

    while parent_uri != doc_uri

      puts "Parent  #{parent_uri}"
      puts "Doc     #{doc_uri}"

      query_string = "identifier:'#{parent_uri}'"

      query = { "bq"            => query_string,
                "return-fields" => @@asn_return_fields,
                "key"           => "#{key}" }

      response  = HTTParty.get(@@ASN_SEARCH_BASE_URL, :query => query)

      if response['hits'] && response['hits']['hit']

        hits    = response['hits']['hit']
        parent  = process_asn_response(hits)[0]
        
        puts "Parent is #{parent}"

        parents.push({
                    uri:                parent[:uri],
                    description:        parent[:description],
                    statement_notation: parent[:statement_notation]
                })

        parent_uri = parent[:is_child_of]

        puts "After push"
        puts "Parent  #{parent_uri}"
        puts "Doc     #{doc_uri}"

      else
        break
      end

    end

    StandardStatement.create(
						:uri			    => uri,
						:doc                => statement[:doc],
  						:material_type	    => type,
  						:material_id	    => id,
  						:description		=> statement[:description],
  						:statement_label    => statement[:statement_label],
  						:statement_notation => statement[:statement_notation],
                        :parents            => parents )

    render json: {  :message => "Successfully added standard." },
                    :status => 200
  end


  #
  # Remove a standard from a material
  #
  # params[:identifier]     The standard statement identifier (URI)
  # params[:material_type]  The material type
  # params[:material_id]    The material ID
  #
  def remove_materials_standard

    uri     = params[:identifier]
    type    = params[:material_type]
    id      = params[:material_id]

    existing = StandardStatement.find_by_uri_and_material_type_and_material_id(
                                                                        uri,
                                                                        type,
                                                                        id )
    if existing.nil?
        render json: {  :message => "No existing standard statement to delete." },
                        :status => 200
    end

    existing.destroy

    render json: {  :message => "Successfully removed standard." },
                    :status => 200
  end


  #
  # Get standard statements from ASN query
  #
  # params[:asn_document_id]                 The document URI
  # params[:asn_statement_notation_query]    The statement notation to match
  # params[:asn_statement_label_query]       The statement label to match
  # params[:asn_description_query]           Text in the description to match
  #
  # Optionally supply material_type and material_id to populate
  # the is_applied property.
  #
  # params[:start]                          The start index
  #
  def get_standard_statements

    key                     = ENV['ASN_API_KEY']
    document_id             = params[:asn_document_id]
    statement_notation_q    = params[:asn_statement_notation_query]
    statement_label_q       = params[:asn_statement_label_query]
    description_q           = params[:asn_description_query]

    material_type           = params[:material_type]
    material_id             = params[:material_id]

    start                   = params[:start]

    applied_map = {}

    #
    # Prevent anonymous user from using this as open ASN proxy.
    # Though this should not be encountered if before_filters are
    # configured correctly to check for author/admin/project admin on
    # the specified material.
    #
    if current_visitor.anonymous?
        render json: {:message => "Access denied to standards API."}, 
                        :status => 403
    end

    #
    # See if we can populate is_applied data
    #
    if material_type.present? && material_id.present?
        statements = StandardStatement.find_all_by_material_type_and_material_id(material_type, material_id)

        statements.each { |s| applied_map[s.uri] = true }
    end

    # 
    # Build query string
    #
    query_string = "(and is_part_of:'#{document_id}' type:'Statement'"

    #
    # Notation doesn't seem to match wildcards (this is a "literal" field
    # type, though I thought the documentation says it allows wildcards in 
    # literal fields...)
    #
    if statement_notation_q.present?
        query_string << " statement_notation:'#{statement_notation_q}'"
    end

    if statement_label_q.present?
        query_string << " statement_label:'#{statement_label_q}'"
    end

    if description_q.present?
        query_string << " description:'*#{description_q}*'"
    end

    query_string << ")"

    #
    # Sort order.
    # Notes:
    # list_id is null on NGSS.
    #
    rank = "identifier"

    #
    # See http://toolkit.asn.desire2learn.com/documentation/asn-search
    #
    query = {   "bq"            => query_string,
                "return-fields" => @@asn_return_fields,
                "rank"          => rank,
                "key"           => "#{key}" }

    if start.present?
        query["start"] = start
    end

    response = HTTParty.get(@@ASN_SEARCH_BASE_URL, :query => query)

    #
    # Might need to look further into how ASN returns 
    # error codes. For now return empty results if we can't 
    # find the key we need in the returned json.
    #
    if !response.key?("hits")
        render json: {:statements => []}, :status => 200
        return
    end

    count = response["hits"]["found"]
    start = response["hits"]["start"]

    hits = response["hits"]["hit"]

    statements = process_asn_response(hits, applied_map)

    render json: {:count => count, :start => start, :statements => statements}, :status => 200
 
  end


  private


  #
  # Process the resulting json of an ASN query and
  # transform it into something more compatible with our object model.
  #
  def process_asn_response(hits, applied_map = {})

    #
    # Find our local peristed copy of the document these statements belong to.
    #
    docs = StandardDocument.all
    docs_map = {}
    docs.map { |d| docs_map[d.uri] = d }

    statements = []

    for hit in hits
   
        #
        # Document this statement belongs to.
        #
        doc = docs_map[hit["data"]["is_part_of"][0]]

        statements.push( {

            # Use join() on these arrays. Sometimes a "description" will
            # contain multiple array elements. 
            # It also handles empty array.
            uri:                hit["data"]["identifier"][0],

            #
            # Include a "key" to help React clients. 
            #
            # key:                hit["data"]["identifier"][0],

            description:        hit["data"]["description"],
            statement_label:    hit["data"]["statement_label"].join(" "),
            statement_notation: hit["data"]["statement_notation"].join(" "),
            doc:                doc.nil? ? "Unknown" : doc.name,
            is_child_of:        hit["data"]["is_child_of"][0],
            is_part_of:         hit["data"]["is_part_of"][0],
            list_id:            hit["data"]["list_id"][0],
            is_applied:         applied_map.key?(hit["data"]["identifier"][0]) ?
                                    true : false

        })
    end

    statements
 
  end



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

  #
  # Validate that parameters contain a valid material type and id
  #
  def validate_material

    type    = params[:material_type]
    id      = params[:material_id]

    begin
        item = get_materials_item id, type
    rescue ActiveRecord::RecordNotFound => rnf
        render json: {  
                :message => "Invalid material type (#{type}) or id (#{id})"}, 
                :status => 400
        return
    end

  end

  #
  # Validate that the ASN API key is configured
  #
  def validate_asn_api_key

    key = ENV['ASN_API_KEY']

    if !key
        render json: {:message => "No ASN API key configured."}, :status => 500 
        return false
    end

    return true
  end

  #
  # Check authorization for setting materials standards or accessing ASN.
  #
  def validate_standards_permissions

    if !validate_material
        return
    end

    type    = params[:material_type]
    id      = params[:material_id]

    item = get_materials_item id, type

    if !(policy(item).admin_or_material_admin? || policy(item).author?)
        render json: {:message => "You do not have permission to modify this material."}, :status => 403
        return
    end

  end

end

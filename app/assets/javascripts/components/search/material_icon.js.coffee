{div, a, img} = React.DOM

window.SMaterialIconClass = React.createClass

  displayName: "SMaterialIconClass"

  render: ->

    material        = @props.material
    icon            = material.icon
    starred         = material.is_favorite

    configuration   = @props.configuration
    enableFavorites = false
    favOutlineClass    = ""

    #
    # Get display configuration info.
    #
    if configuration
        enableFavorites = configuration.enableFavorites
        favClassMap     = configuration.favoriteClassMap
        favOutlineClass = configuration.favoriteOutlineClass
    else
        #
        # Set some defaults
        #
        favClassMap = {
            true:   "stem-finder-result-favorite-active",
            false:  "stem-finder-result-favorite"
        }

    #
    # Set the icon image
    #
    if icon.url is null 
        border = '1px solid black'
    else
        border = '0px'

    containerStyle = { 'border': border }

    #
    # Check for caller overrides
    #
    for prop in ['width', 'height'] 
        if configuration[prop]
            containerStyle[prop] = configuration[prop]

    #
    # Create the favorites div if enabled.
    #
    if enableFavorites
    
        #
        # Set favorite info.
        #
        favClass        = favClassMap[false]
        favStar         = "\u2605"
        outlineStar     = "\u2606"
        if starred
            favClass += " " + favClassMap[true]
        else
            outlineClass = favClass + " " + favOutlineClass

        favDiv = (div { className:  favClass,       \
                        onClick:    @handleClick,   \
                        dangerouslySetInnerHTML: {__html: favStar} } )
        if ! starred
            outlineDiv = (div { className: outlineClass,    \
                            style: {color: '#CCCCCC'},      \
                            onClick:    @handleClick,       \
                            dangerouslySetInnerHTML: {__html: outlineStar} } )

    (div {  className: 'material_icon', style: containerStyle },

        (a {className: 'thumb_link', href: material.links.browse && material.links.browse.url},
            (img {  src: icon.url, width: '100%'})
        )
        favDiv
        outlineDiv
    )

  handleClick: ->
    material = @props.material

    apiUrl 	= null
    params	= {}

    if !Portal.currentUser.isTeacher
        alert("You must be logged in as a teacher to favorite material.");
        return

    if material.is_favorite 
        apiUrl = Portal.API_V1.MATERIALS_REMOVE_FAVORITE
        params = {  favorite_id:    material.favorite_id    }
    else
        apiUrl = Portal.API_V1.MATERIALS_ADD_FAVORITE
        params = {  id:             material.id,                    \
                    material_type:  material.class_name_underscored }

    jQuery.ajax
      url: apiUrl
      data: params
      type: 'POST'
      dataType: 'json'
      success: (data) =>
        material.is_favorite = !material.is_favorite
        material.favorite_id = data.favorite_id
        @setState { material: material }
      error: (jqXHR, textStatus, errorThrown) =>
        console.error("ERROR", jqXHR.responseText, jqXHR)

window.SMaterialIcon = React.createFactory SMaterialIconClass

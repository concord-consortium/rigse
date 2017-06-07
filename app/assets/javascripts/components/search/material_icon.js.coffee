{div, a, img} = React.DOM

window.SMaterialIconClass = React.createClass
  displayName: "SMaterialIconClass"
  render: ->
    material    = @props.material
    icon        = material.icon
    starred     = material.is_favorite
    starURL     = Portal.favorite_image_map[starred]

    if icon.url is null 
        border = '1px solid black'
    else
        border = '0px'
    
    (div {className: 'material_icon', style: {'border': border} },
        (a {className: 'thumb_link', href: material.links.browse && material.links.browse.url},
            (img {className: 'stackable_left',  \
                    zIndex: 1,                  \
                    src: icon.url,              \
                    width: '100%' } )
        )
        (img {className: 'stackable_right', \
                zIndex: 2,                  \
                src: starURL,               \
                width: '32px',              \
                height: '32px',             \
                onClick: @handleClick } )
    )

  handleClick: ->
    material = @props.material
    # alert("Click " + material.id + " " + material.class_name_underscored)
    # console.log("DEBUG!!!")
    # console.log(@props)

    apiUrl 	= null
    params	= {}

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
      dataType: 'json'
      success: (data) =>
        console.info("DEBUG", data.message, data)
        material.is_favorite = !material.is_favorite
        material.favorite_id = data.favorite_id
        @setState {material: material}
      error: (jqXHR, textStatus, errorThrown) =>
        console.error("ERROR", jqXHR.responseText, jqXHR)

window.SMaterialIcon = React.createFactory SMaterialIconClass

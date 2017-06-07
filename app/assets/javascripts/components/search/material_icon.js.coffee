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
    alert("Click " + material.id + " " + material.class_name_underscored)
    # console.log("DEBUG!!!")
    # console.log(@props)

window.SMaterialIcon = React.createFactory SMaterialIconClass

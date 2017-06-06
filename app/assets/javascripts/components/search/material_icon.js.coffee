{div, a, img} = React.DOM

window.SMaterialIconClass = React.createClass
  displayName: "SMaterialIconClass"
  render: ->
    material    = @props.material
    icon        = material.icon
    starred     = material.is_favorite
    starURL     = Portal.favorite_image_map[starred]

    ###
    console.log("Material " + material.id + " " +
                material.class_name + " " +
                "favorite: " + starred + " " +
                "url " + starURL )
    ### 

    (div {className: 'material_icon'},
        (a {className: 'thumb_link', href: material.links.browse && material.links.browse.url},
            (img {className: 'stackable_left', zIndex: 1, src: icon.url, width: '100%' })
        )
        (img {className: 'stackable_right', zIndex: 2, right: '0px', src: starURL, width: '32px', height: '32px' })
    )

window.SMaterialIcon = React.createFactory SMaterialIconClass

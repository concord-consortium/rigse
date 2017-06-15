{div} = React.DOM

window.SMaterialClass = React.createClass
  displayName: "SMaterialClass"
  render: ->
    material = @props.material

    configuration = {
        enableFavorites:    true,
        favoriteClassMap:   {
            true:   "legacy-favorite-active",
            false:  "legacy-favorite"
        },
        favoriteOutlineClass:   "legacy-favorite-outline"
    }

    (div {
        className: 'material_list_item'
        'data-material_id': material.id
        'data-material_name': material.name
        id: "search_#{material.class_name_underscored}_#{material.id}"
      },
      (div {className: 'main-part'},
        (SMaterialIcon {material: material, \
                        configuration: configuration } )
        (SMaterialInfo {material: material})
        (SMaterialBody {material: material})
      )
      (SMaterialDetails {material: material})
    )

window.SMaterial = React.createFactory SMaterialClass

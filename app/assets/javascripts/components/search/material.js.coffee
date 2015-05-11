{div} = React.DOM

window.SMaterialClass = React.createClass
  render: ->
    material = @props.material
    (div {
        className: 'material_list_item'
        'data-material_id': material.id
        'data-material_name': material.name
        id: "search_#{material.class_name_underscored}_#{material.id}"
      },
      (div {className: 'main-part'},
        (SMaterialIcon {material: material})
        (SMaterialInfo {material: material})
        (SMaterialBody {material: material})
      )
      (SMaterialDetails {material: material})
    )

window.SMaterial = React.createFactory SMaterialClass

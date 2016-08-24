{div} = React.DOM

window.SMaterialsListClass = React.createClass
  displayName: "SMaterialsListClass"
  render: ->
    (div {className: 'material_list'},
      for material in @props.materials
        (SMaterial {material: material, key: "#{material.class_name}#{material.id}"})
    )

window.SMaterialsList = React.createFactory SMaterialsListClass

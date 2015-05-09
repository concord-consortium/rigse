{div} = React.DOM

window.MBMaterialsCollectionClass = React.createClass
  render: ->
    (div {className: 'mb-collection'},
      (div {className: 'mb-collection-name'}, @props.name)
      for material in @props.materials
        (MBMaterial material: material)
    )

window.MBMaterialsCollection = React.createFactory MBMaterialsCollectionClass

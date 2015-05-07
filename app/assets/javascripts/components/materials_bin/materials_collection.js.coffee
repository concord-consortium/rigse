{div} = React.DOM

window.MaterialsCollectionClass = React.createClass
  render: ->
    (div {className: 'mb-collection'},
      (div {className: 'mb-collection-name'}, @props.name)
      for material in @props.materials
        (Material material: material)
    )

window.MaterialsCollection = React.createFactory MaterialsCollectionClass

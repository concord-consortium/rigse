{div} = React.DOM

window.MatarialsContainerClass = React.createClass
  getInitialState: ->
    {collectionsData: []}

  componentDidMount: ->
    # Fake data for now, in the future it will be obtained using AJAX.
    @setState collectionsData: [
      {
        "name": "Collection 1",
        "materials": [
          {
            "name": "Will the air be clean enough to breathe?"
          },
          {
            "name": "Are the cars fast enough?"
          }
        ]
      },
      {
        "name": "Collection 2",
        "materials": [
          {
            "name": "Foo?"
          },
          {
            "name": "Bar?"
          }
        ]
      }
    ]

  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      for collection in @state.collectionsData
        (MaterialsCollection {name: collection.name, materials: collection.materials})
    )

window.MaterialsContainer = React.createFactory MatarialsContainerClass

# Helper components:

MaterialsCollection = React.createFactory React.createClass
  render: ->
    (div {},
      (div {}, @props.name)
      for material in @props.materials
        (Material material)
    )

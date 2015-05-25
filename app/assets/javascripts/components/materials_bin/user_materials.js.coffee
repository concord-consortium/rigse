{div} = React.DOM

window.MBUserMaterialsClass = React.createClass
  getInitialState: ->
    materialsVisible: false

  toggleMaterials: ->
    @setState materialsVisible: not @state.materialsVisible

  render: ->
    (div {},
      (div {className: 'mb-collection-name mb-clickable', onClick: @toggleMaterials}, @props.name)
      (MBUserMaterialsContainer userId: @props.userId, visible: @state.materialsVisible)
    )

window.MBUserMaterials = React.createFactory MBUserMaterialsClass

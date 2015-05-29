{div, span} = React.DOM

window.MBUserMaterialsClass = React.createClass
  getInitialState: ->
    materialsVisible: false

  toggleMaterials: ->
    @setState materialsVisible: not @state.materialsVisible

  renderToggleIcon: ->
    if @state.materialsVisible then '-' else '+'

  render: ->
    (div {},
      (div {className: 'mb-collection-name mb-clickable', onClick: @toggleMaterials},
        (span className: 'mb-toggle-symbol', @renderToggleIcon())
        ' '
        @props.name
      )
      (MBUserMaterialsContainer userId: @props.userId, visible: @state.materialsVisible)
    )

window.MBUserMaterials = React.createFactory MBUserMaterialsClass

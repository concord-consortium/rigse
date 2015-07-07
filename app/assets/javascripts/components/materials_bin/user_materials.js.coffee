UserMaterialsContainer = React.createFactory require 'components/materials_bin/user_materials_container'

{div, span} = React.DOM

module.exports = React.createClass
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
      (UserMaterialsContainer userId: @props.userId, visible: @state.materialsVisible)
    )

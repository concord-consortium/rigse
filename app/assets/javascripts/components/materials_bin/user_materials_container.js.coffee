{div} = React.DOM

window.MBUserMaterialsContainerClass = React.createClass
  mixins: [MBFetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS
  requestParams: ->
    user_id: @props.userId
  # ---

  render: ->
    (div {className: @getVisibilityClass()},
      if @state.materials
        (MBMaterialsCollection materials: @state.materials)
      else
        (div {}, 'Loading...')
    )

window.MBUserMaterialsContainer = React.createFactory MBUserMaterialsContainerClass

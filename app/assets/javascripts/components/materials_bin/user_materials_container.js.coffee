{div} = React.DOM

window.MBUserMaterialsContainerClass = React.createClass
  mixins: [MBFetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS
  requestParams: ->
    if @props.assignToSpecificClass
      user_id: @props.userId
      assigned_to_class: @props.assignToSpecificClass
    else
      user_id: @props.userId
  # ---

  render: ->
    (div {className: @getVisibilityClass()},
      if @state.materials
        (MBMaterialsCollection
          materials: @state.materials
          assignToSpecificClass: @props.assignToSpecificClass
          archive: @archive
        )
      else
        (div {}, 'Loading...')
    )

window.MBUserMaterialsContainer = React.createFactory MBUserMaterialsContainerClass

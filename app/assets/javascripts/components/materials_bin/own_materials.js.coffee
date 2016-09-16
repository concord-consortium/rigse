{div} = React.DOM

window.MBOwnMaterialsClass = React.createClass
  mixins: [MBFetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_OWN
  requestParams: ->
    if @props.assignToSpecificClass
      assigned_to_class: @props.assignToSpecificClass
    else
      {}
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.materials?
        (MBMaterialsCollection
          name: 'My activities'
          materials: @state.materials
          archive: @archiveSingle
          assignToSpecificClass: @props.assignToSpecificClass
        )
      else
        (div {}, 'Loading...')
    )

window.MBOwnMaterials = React.createFactory MBOwnMaterialsClass

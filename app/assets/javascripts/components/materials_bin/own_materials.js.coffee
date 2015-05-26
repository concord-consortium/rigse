fetchDataMixin = require 'components/materials_bin/fetch_data_mixin'

{div} = React.DOM

window.MBOwnMaterialsClass = React.createClass
  mixins: [fetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_OWN
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.materials?
        (MBMaterialsCollection
          name: 'My activities'
          materials: @state.materials
        )
      else
        (div {}, 'Loading...')
    )

window.MBOwnMaterials = React.createFactory MBOwnMaterialsClass

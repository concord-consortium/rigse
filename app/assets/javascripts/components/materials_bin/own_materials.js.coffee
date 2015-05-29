fetchDataMixin = require 'components/materials_bin/fetch_data_mixin'
MaterialsCollection = React.createFactory require 'components/materials_bin/materials_collection'

{div} = React.DOM

module.exports = React.createClass
  mixins: [fetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_OWN
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.materials?
        (MaterialsCollection
          name: 'My activities'
          materials: @state.materials
        )
      else
        (div {}, 'Loading...')
    )

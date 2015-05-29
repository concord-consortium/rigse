fetchDataMixin = require 'components/materials_bin/fetch_data_mixin'
MaterialsCollection = React.createFactory require 'components/materials_bin/materials_collection'

{div} = React.DOM

module.exports = React.createClass
  mixins: [fetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'materials'
  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS
  requestParams: ->
    user_id: @props.userId
  # ---

  render: ->
    (div {className: @getVisibilityClass()},
      if @state.materials
        (MaterialsCollection materials: @state.materials)
      else
        (div {}, 'Loading...')
    )

fetchDataMixin = require 'components/materials_bin/fetch_data_mixin'
UserMaterials = React.createFactory require 'components/materials_bin/user_materials'

{div} = React.DOM

module.exports = React.createClass
  mixins: [fetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS_AUTHORS
  dataStateKey: 'authors'
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.authors?
        for author in @state.authors
          (UserMaterials
            key: author.id
            name: author.name
            userId: author.id
          )
      else
        (div {}, 'Loading...')
    )


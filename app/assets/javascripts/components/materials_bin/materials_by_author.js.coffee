{div} = React.DOM

window.MBMaterialsByAuthorClass = React.createClass
  mixins: [MBFetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataUrl: Portal.API_V1.MATERIALS_BIN_UNOFFICIAL_MATERIALS_AUTHORS
  dataStateKey: 'authors'
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.authors?
        for author in @state.authors
          (MBUserMaterials
            key: author.id
            name: author.name
            userId: author.id
          )
      else
        (div {}, 'Loading...')
    )

window.MBMaterialsByAuthor = React.createFactory MBMaterialsByAuthorClass

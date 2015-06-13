{div} = React.DOM

window.MBCollectionsClass = React.createClass
  mixins: [MBFetchDataMixin]
  # --- MBFetchDataMixin config ---
  dataStateKey: 'collectionsData'
  dataUrl: Portal.API_V1.MATERIALS_BIN_COLLECTIONS
  requestParams: ->
    id: @props.collections.map (c) -> c.id
  # ---

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.collectionsData?
        for collection, idx in @state.collectionsData
          (MBMaterialsCollection
            key: idx
            name: collection.name
            materials: collection.materials
            # Merge extra properties that can be provided in collections array.
            teacherGuideUrl: @props.collections[idx].teacherGuideUrl
          )
      else
        (div {}, 'Loading...')
    )

window.MBCollections = React.createFactory MBCollectionsClass

{div} = React.DOM

window.MBMatarialsContainerClass = React.createClass
  propTypes:
    # Provide collections array OR ownMaterials: true
    collections: React.PropTypes.array
    ownMaterials: React.PropTypes.bool
    visible: React.PropTypes.bool

  getInitialState: ->
    {collectionsData: null}

  componentDidMount: ->
    # Download data only if component is visibile.
    @fetchData() if @props.visible

  componentWillReceiveProps: (nextProps) ->
    # Download data only if component is going to be visibile.
    @fetchData() if nextProps.visible

  fetchData: ->
    # Don't download data if it's been already done.
    return if @state.collectionsData?
    if @props.ownMaterials
      @fetchOwnMaterials()
    else if @props.collections
      @fetchCollectionsData()

  fetchCollectionsData: ->
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_COLLECTION_DATA
      data: id: @props.collections.map (c) -> c.id
      dataType: 'json'
      success: (data) =>
        for col, idx in data
          # Merge extra properties that can be provided in collections array.
          col.teacherGuideUrl = @props.collections[idx].teacherGuideUrl
        @setState collectionsData: data if @isMounted()

  fetchOwnMaterials: ->
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_OWN
      dataType: 'json'
      success: (data) =>
        # Keep structure of material collection.
        @setState collectionsData: [{name: 'My activities', materials: data}] if @isMounted()

  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.collectionsData?
        for collection, idx in @state.collectionsData
          (MBMaterialsCollection
            name: collection.name
            materials: collection.materials
            teacherGuideUrl: collection.teacherGuideUrl
          )
      else
        (div {}, 'Loading...')
    )

window.MBMaterialsContainer = React.createFactory MBMatarialsContainerClass

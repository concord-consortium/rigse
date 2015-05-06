{div} = React.DOM

window.MatarialsContainerClass = React.createClass
  propTypes:
    collections: React.PropTypes.array.isRequired
    visible: React.PropTypes.bool

  getInitialState: ->
    {collectionsData: null}

  componentDidMount: ->
    # Download data only if component is visibile.
    @fetchCollectionsData() if @props.visible

  componentWillReceiveProps: (nextProps) ->
    # Download data only if component is going to be visibile.
    @fetchCollectionsData() if nextProps.visible

  fetchCollectionsData: ->
    # Don't download data if it's been already done.
    return if @state.collectionsData?
    jQuery.ajax
      url: API_V1.MATERIALS_COLLECTION_DATA
      data:
        id: @props.collections
      dataType: 'json'
      success: (data) =>
        @setState collectionsData: data if @isMounted()

  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    if @state.collectionsData?
      (div {className: className},
        for collection in @state.collectionsData
          (MaterialsCollection {name: collection.name, materials: collection.materials})
      )
    else
      (div {})

window.MaterialsContainer = React.createFactory MatarialsContainerClass

# Helper components:

MaterialsCollection = React.createFactory React.createClass
  render: ->
    (div {},
      (div {}, @props.name)
      for material in @props.materials
        (Material material)
    )

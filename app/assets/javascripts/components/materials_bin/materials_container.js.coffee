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
      url: Portal.API_V1.MATERIALS_COLLECTION_DATA
      data: @props.collections
      dataType: 'json'
      success: (data) =>
        @setState collectionsData: data if @isMounted()

  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    className = "mb-cell #{@getVisibilityClass()}"
    (div {className: className},
      if @state.collectionsData?
        for collection in @state.collectionsData
          (MaterialsCollection {name: collection.name, materials: collection.materials})
      else
        (div {}, 'Loading...')
    )

window.MaterialsContainer = React.createFactory MatarialsContainerClass

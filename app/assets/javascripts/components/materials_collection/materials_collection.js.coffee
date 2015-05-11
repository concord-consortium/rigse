{div, span, a} = React.DOM

window.MaterialsCollectionClass = React.createClass
  getInitialState: ->
    materials: []
    truncated: true

  componentDidMount: ->
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_COLLECTION_DATA
      data: id: @props.collection
      dataType: 'json'
      success: (data) =>
        @setState materials: data[0].materials if @isMounted()

  toggle: (e) ->
    @setState truncated: not @state.truncated
    e.preventDefault()

  getMaterialsList: ->
    if @state.truncated
      @state.materials.slice 0, @props.limit
    else
      @state.materials

  renderTruncationToggle: ->
    (a {className: 'mc-truncate', onClick: @toggle, href: ''},
      (span {},
        if @state.truncated
          'Show all materials in this collection'
        else
          'Hide materials'
      )
    )

  render: ->
    (div {},
      (SMaterialsList {materials: @getMaterialsList()})
      @renderTruncationToggle()
    )

window.MaterialsCollection = React.createFactory MaterialsCollectionClass

Portal.renderMaterialsCollection = (collectionId, limit, selectorOrElement) ->
  React.render MaterialsCollection(collection: collectionId, limit: limit), jQuery(selectorOrElement)[0]

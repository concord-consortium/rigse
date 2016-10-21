{div, span, a, i, h1} = React.DOM

shuffle = (a) ->
  idx = a.length
  while --idx > 0
    j = ~~(Math.random() * (idx + 1))
    t = a[j]
    a[j] = a[idx]
    a[idx] = t
  a

window.MaterialsCollectionClass = React.createClass
  getDefaultProps: ->
    randomize: false
    limit: Infinity
    header: null

  getInitialState: ->
    materials: []
    truncated: true

  componentDidMount: ->
    {randomize} = @props
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS
      data: id: @props.collection
      dataType: 'json'
      success: (data) =>
        materials = data[0].materials
        materials = shuffle(materials) if randomize
        @setState materials: materials if @isMounted()

  toggle: (e) ->
    @setState truncated: not @state.truncated
    e.preventDefault()

  getMaterialsList: ->
    if @state.truncated
      @state.materials.slice 0, @props.limit
    else
      @state.materials

  renderTruncationToggle: ->
    return if @state.materials.length <= @props.limit
    chevron = if @state.truncated then 'down' else 'up'
    text = if @state.truncated then ' show all materials' else ' show less'
    (a {className: 'mc-truncate', onClick: @toggle, href: ''},
      (i {className: "fa fa-chevron-#{chevron}"})
      (span {className: 'mc-truncate-text'}, text)
    )

  render: ->
    headerVisible = @props.header && @state.materials.length > 0
    (div {},
      if headerVisible
        (h1 {className: 'collection-header'}, @props.header)
      (SMaterialsList {materials: @getMaterialsList()})
      @renderTruncationToggle()
    )

window.MaterialsCollection = React.createFactory MaterialsCollectionClass

# Supported options: limit, randomize, header
# Keep API backward compatible, so accept either 'limit' option as the last argument or hash.
Portal.renderMaterialsCollection = (collectionId, selectorOrElement, limitOrOptions = Infinity) ->
  props = if typeof limitOrOptions == 'number'
            {limit: limitOrOptions}
          else
            limitOrOptions
  props.collection = collectionId
  ReactDOM.render MaterialsCollection(props), jQuery(selectorOrElement)[0]

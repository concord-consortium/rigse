{div, span, a, i} = React.DOM

module.exports = React.createClass
  getInitialState: ->
    materials: []
    truncated: true

  componentDidMount: ->
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_BIN_COLLECTIONS
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
    return if @state.materials.length <= @props.limit
    chevron = if @state.truncated then 'down' else 'up'
    text = if @state.truncated then ' show all materials' else ' show less'
    (a {className: 'mc-truncate', onClick: @toggle, href: ''},
      (i {className: "fa fa-chevron-#{chevron}"})
      (span {className: 'mc-truncate-text'}, text)
    )

  render: ->
    (div {},
      (SMaterialsList {materials: @getMaterialsList()})
      @renderTruncationToggle()
    )

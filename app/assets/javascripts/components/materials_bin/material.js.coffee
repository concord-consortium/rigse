{div, span, a} = React.DOM

window.MaterialClass = React.createClass
  getInitialState: ->
    {
      descriptionVisible: false
    }

  toggleDescription: (e) ->
    @setState descriptionVisible: not @state.descriptionVisible
    e.preventDefault()

  render: ->
    data = @props.material
    (div {className: 'mb-material'},
      (span {className: 'mb-material-links'},
        if data.description? && data.description != ''
          (a {className: 'mb-toggle-info', href: '', onClick: @toggleDescription},
            (span {className: 'mb-toggle-info-text'}, 'Info ')
          )
        if data.links? && data.links.preview?
          (a {className: 'mb-run', href: data.links.preview.url, target: '_blank'},
            (span {className: 'mb-run-text'}, 'Run')
          )
      )
      (span {className: 'mb-material-name'}, data.name)
      (MaterialDescription
        description: data.description
        visible: @state.descriptionVisible
      )
    )

window.Material = React.createFactory MaterialClass

# Helper components:

MaterialDescription = React.createFactory React.createClass
  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    (div {className: "mb-material-description #{@getVisibilityClass()}"},
      @props.description
    )

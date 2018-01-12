{div} = React.DOM

window.TextPreviewClass = React.createClass

  displayName: "TextPreviewClass"

  togglePreview: (e) -> 
    config = @props.config
    config.preview = !config.preview
    @setState { config: config }

  render: ->
    
    PREVIEW_LENGTH = 17

    text    = @props.config.text
    preview = @props.config.preview

    isArray = Array.isArray || (o) -> return {}.toString.call(o) is '[object Array]'
    if isArray text
      text = text.join(' ')

    if preview is true
      if text.length > PREVIEW_LENGTH
        text = text.substring(0, PREVIEW_LENGTH) + " ..."

    (div {onClick: @togglePreview, style: {cursor: "default"} },
      text 
    )


window.TextPreview = React.createFactory TextPreviewClass


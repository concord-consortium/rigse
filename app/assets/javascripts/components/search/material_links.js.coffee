{div, a} = React.DOM

window.SMaterialLinksClass = React.createClass
  render: ->
    (div {},
      for link, idx in @props.links
        if link.type is 'dropdown'
          (SMaterialDropdownLink {key: idx, link: link})
        else
          (SMaterialLink {key: idx, link: link})
    )

window.SMaterialLinks = React.createFactory SMaterialLinksClass

window.SGenericLinkClass = React.createClass
  wrapOnClick: (str) ->
    return ->
      eval(str)

  render: ->
    link = @props.link
    link.className = 'button' unless link.className?
    if typeof link.onclick is 'string'
      link.onclick = @wrapOnClick link.onclick
    (a
      href: link.url
      className: link.className
      target: link.target
      onClick: link.onclick
      dangerouslySetInnerHTML: {__html: link.text}
    )

window.SGenericLink = React.createFactory SGenericLinkClass

window.SMaterialLinkClass = React.createClass
  render: ->
    link = @props.link
    (div {key: link.key, style: {float: 'right', marginRight: '5px'}},
      (SGenericLink {link: link})
    )

window.SMaterialLink = React.createFactory SMaterialLinkClass

window.SMaterialDropdownLinkClass = React.createClass
  handleClick: (event) ->
    hideSharelinks()
    if !event.target.nextSibling.visible()
      event.target.nextSibling.show()
      event.target.nextSibling.addClassName('visible')
      event.target.innerHTML = @expandedText

  render: ->
    link = @props.link
    @expandedText = link.expandedText
    link.onclick = @handleClick
    (div {key: link.key, style: {float: 'right'}},
      (SGenericLink {link: link})
      (div {className: 'Expand_Collapse Expand_Collapse_preview', style: {display: 'none'}},
        for item, idx in link.options
          (div {key: idx, className: 'preview_link'},
            (SGenericLink {link: item})
          )
      )
    )

window.SMaterialDropdownLink = React.createFactory SMaterialDropdownLinkClass

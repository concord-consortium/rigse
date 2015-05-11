{div, a, img} = React.DOM

window.SMaterialIconClass = React.createClass
  render: ->
    material = @props.material
    icon = material.icon
    (div {className: 'material_icon'},
      (a {className: 'thumb_link', href: material.links.browse.url},
        (img {src: icon.url, width: '100%'})
      )
    )

window.SMaterialIcon = React.createFactory SMaterialIconClass

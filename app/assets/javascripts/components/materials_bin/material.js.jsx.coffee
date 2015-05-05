{div} = React.DOM

window.MaterialClass = React.createClass
  render: ->
    (div {className: 'mb-material'}, @props.name)

window.Material = React.createFactory MaterialClass

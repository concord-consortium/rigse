MaterialIcon = React.createClass
  render: ->
    material = @props.material
    icon = material.icon
    return `(
      <div className='material_icon'>
        <a className='thumb_link' href={material.links.browse.url}>
          <img src={icon.url} width='100%' />
        </a>
      </div>
    )`

window.MaterialIcon = MaterialIcon

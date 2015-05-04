MaterialHeader = React.createClass
  render: ->
    material = @props.material
    return `(
      <span className='material_header'>
        <span className='material_meta_data'>
          <span className={material.requires_java ? 'JNLPJavaRequirement' : 'NoJavaRequirement'}>
            {material.requires_java ? 'Requires download' : 'Runs in browser'}
          </span>
          <span className='is_official'>
            { material.is_official ? 'Official' : 'Community' }
          </span>
        </span>
        <br />
        { material.browse_link ? <a href={material.browse_link.url}>{material.name}</a> : '' }
        {material.edit_link}
        {material.launch_link}
      </span>
    )`

window.MaterialHeader = MaterialHeader

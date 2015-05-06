MaterialHeader = React.createClass
  render: ->
    material = @props.material
    edit_link = if material.links.edit? then `<span className={'superTiny'}><GenericLink link={material.links.edit} /></span>` else ''
    iframe_edit_link = if material.links.external_edit_iframe? then `<span className={'superTiny'}><GenericLink link={material.links.external_edit_iframe} /></span>` else ''
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
        { material.links.browse ? <a href={material.links.browse.url}>{material.name}</a> : '{material.name}' } {edit_link} {iframe_edit_link}
      </span>
    )`

window.MaterialHeader = MaterialHeader

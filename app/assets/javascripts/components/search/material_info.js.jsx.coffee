MaterialInfo = React.createClass
  render: ->
    material = @props.material
    for own key,link of material.links
      link.key = key

    links = []
    links.push material.links.preview           if material.links.preview
    links.push material.links.external_edit     if material.links.external_edit
    links.push material.links.external_copy     if material.links.external_copy
    links.push material.links.teacher_guide     if material.links.teacher_guide
    links.push material.links.assign_material   if material.links.assign_material
    links.push material.links.assign_collection if material.links.assign_collection
    return `(
      <div>
        <div style={{overflow: "hidden"}}>
          <table width='100%'>
            <tr>
              <td>
                <MaterialLinks links={links} />
              </td>
            </tr>
            <tr>
              <td>
                <MaterialHeader material={material} />
                { material.parent ? <span>from {material.parent.type} "{material.parent.name}"</span> : '' }
                <div>
                  <span style={{fontWeight: 'bold'}}>
                    By {material.user.name}
                  </span>
                </div>
              </td>
            </tr>
            <tr>
              <td>
                { material.assigned_classes && material.assigned_classes.length > 0 ?
                  <span className='assignedTo'>(Assigned to {material.assigned_classes.join(', ')})</span>
                  :
                  ''
                }
              </td>
            </tr>
          </table>
        </div>
      </div>
    )`

window.MaterialInfo = MaterialInfo

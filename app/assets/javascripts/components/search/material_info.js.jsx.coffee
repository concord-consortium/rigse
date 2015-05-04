MaterialInfo = React.createClass
  render: ->
    material = @props.material
    links = [material.preview_link, material.external_edit_link, material.external_copy_link, material.assign_material_link, material.teacher_guide_link, material.assign_collection_link]
    return `(
      <div>
        <div style={{overflow: "hidden"}}>
          <table width='100%'>
            <tr>
              <td></td>
              <td>
                <MaterialHeader material={material} />
                { material.parent ? <span>from {material.parent.type} "{material.parent.name}"</span> : '' }
                <div>
                  <span style={{fontWeight: 'bold'}}>
                    By {material.user.name}
                  </span>
                </div>
              </td>
              <td width='90px'>
                <MaterialLinks links={links} />
              </td>
            </tr>
            <tr>
              <td colspan='3'>
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

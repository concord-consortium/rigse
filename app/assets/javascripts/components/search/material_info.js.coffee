{div, table, tr, td, span} = React.DOM

window.SMaterialInfoClass = React.createClass
  renderLinks: ->
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

    (SMaterialLinks {links: links})

  renderParentInfo: ->
    if @props.material.parent
      (span {}, "from #{@props.material.parent.type} \"#{@props.material.parent.name}\"")

  renderAuthorInfo: ->
    if @props.material.user
      (div {},
        (span {style: {fontWeight: 'bold'}}, "By #{@props.material.user.name}")
      )

  renderClassInfo: ->
    assignedClassess = @props.material.assigned_classes
    if assignedClassess? and assignedClassess.length > 0
      (span {className: 'assignedTo'}, "(Assigned to #{assignedClassess.join(', ')})")

  render: ->
    (div {},
      (div {style: {overflow: 'hidden'}},
        (table {width: '100%'},
          (tr {}, (td {},
            @renderLinks()
          ))
          (tr {}, (td {},
            (SMaterialHeader {material: @props.material})
            @renderParentInfo()
            @renderAuthorInfo()
          ))
          (tr {}, (td {},
            @renderClassInfo()
          ))
        )
      )
    )

window.SMaterialInfo = React.createFactory SMaterialInfoClass

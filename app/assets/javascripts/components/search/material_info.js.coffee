{div, table, tbody, tr, td, span} = React.DOM

window.SMaterialInfoClass = React.createClass
  displayName: "SMaterialInfoClass"
  renderLinks: ->
    material = @props.material
    for own key, link of material.links
      link.key = key

    links = []
    links.push material.links.preview           if material.links.preview
    links.push material.links.print_url         if material.links.print_url
    if material.lara_activity_or_sequence
      links.push material.links.external_lara_edit if material.links.external_lara_edit
    else
      links.push material.links.external_edit if material.links.external_edit
    links.push material.links.external_copy     if material.links.external_copy
    links.push material.links.teacher_guide     if material.links.teacher_guide
    if material.material_type != 'Collection'
      links.push material.links.assign_material   if material.links.assign_material
      links.push material.links.assign_collection if material.links.assign_collection
    links.push material.links.unarchive         if material.links.unarchive

    (SMaterialLinks {links: links})

  renderParentInfo: ->
    if @props.material.parent
      (span {}, "from #{@props.material.parent.type} \"#{@props.material.parent.name}\"")

  renderAuthorInfo: ->
    credits = if @props.material.credits?.length > 0
      @props.material.credits
    else if @props.material.user?.name.length > 0
      @props.material.user.name
    else
      null
    if credits
      (div {},
        (span {style: {fontWeight: 'bold'}}, "By #{credits}")
      )

  renderClassInfo: ->
    assignedClassess = @props.material.assigned_classes
    if assignedClassess? and assignedClassess.length > 0
      (span {className: 'assignedTo'}, "(Assigned to #{assignedClassess.join(', ')})")

  render: ->
    (div {},
      (div {style: {overflow: 'hidden'}},
        (table {width: '100%'},
          (tbody {},
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
    )

window.SMaterialInfo = React.createFactory SMaterialInfoClass

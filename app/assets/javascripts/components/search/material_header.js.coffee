{span, a, br} = React.DOM

window.SMaterialHeaderClass = React.createClass
  renderMaterialProperties: ->
    # FIXME Make this a generic loop to handle displaying arbitrary properties
    reqDownload = @props.material.material_properties.indexOf('Requires download') isnt -1
    className = if reqDownload then 'RequiresDownload' else 'RunsInBrowser'
    (span {className: className},
      if reqDownload then 'Requires download' else 'Runs in browser'
    )

  render: ->
    material = @props.material
    (span {className: 'material_header'},
      (span {className: 'material_meta_data'},
        @renderMaterialProperties()
        if material.is_official
          (span {className: 'is_official'}, 'Official')
        else
          (span {className: 'is_community'}, 'Community')
        if material.publication_status != 'published'
          (span {className: 'publication_status'}, material.publication_status)
      )
      (br {})
      if material.links.browse?
        (a {href: material.links.browse.url}, material.name)
      else
        material.name
      if material.links.edit?
        (span {className: 'superTiny'},
          (SGenericLink {link: material.links.edit})
        )
      if material.links.external_edit_iframe? and not material.lara_activity_or_sequence
        (span {className: 'superTiny'},
          (SGenericLink {link: material.links.external_edit_iframe})
        )
    )

window.SMaterialHeader = React.createFactory SMaterialHeaderClass

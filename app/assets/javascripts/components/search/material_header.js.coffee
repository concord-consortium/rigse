{span, a, br} = React.DOM

window.SMaterialHeaderClass = React.createClass
  renderJavaReq: ->
    reqJava = @props.material.requires_java
    className = if reqJava then 'JNLPJavaRequirement' else 'NoJavaRequirement'
    (span {className: className},
      if reqJava then 'Requires download' else 'Runs in browser'
    )

  render: ->
    material = @props.material
    (span {className: 'material_header'},
      (span {className: 'material_meta_data'},
        @renderJavaReq()
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
      if material.links.external_edit_iframe?
        (span {className: 'superTiny'},
          (SGenericLink {link: material.links.external_edit_iframe})
        )
    )

window.SMaterialHeader = React.createFactory SMaterialHeaderClass

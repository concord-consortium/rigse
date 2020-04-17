{div, span, a, input} = React.DOM

window.MBMaterialClass = React.createClass
  getInitialState: ->
    {
      descriptionVisible: false
      assigned: @props.material.assigned
    }

  assignToSpecificClass: (e) ->
    Portal.assignMaterialToSpecificClass e.target.checked, @props.assignToSpecificClass, @props.material.id, @props.material.class_name
    @setState assigned: e.target.checked

  toggleDescription: (e) ->
    @setState descriptionVisible: not @state.descriptionVisible
    e.preventDefault()

  assignToClass: (e) ->
    Portal.assignMaterialToClass @props.material.id, @props.material.class_name
    e.preventDefault()

  assignToCollection: (e) ->
    Portal.assignMaterialToCollection @props.material.id, @props.material.class_name
    e.preventDefault()

  hasShortDescription: ->
    @props.material.short_description? && @props.material.short_description != ''

  archive: ->
    Portal.confirm
      message: "Archive '#{@props.material.name}'?"
      callback: () =>
        @props.archive(@props.material.id, @props.material.archive_url)

  render: ->
    data = @props.material
    (div {className: 'mb-material'},
      (span {className: 'mb-material-links'},
        if @props.assignToSpecificClass
          (input {type: 'checkbox', onChange: @assignToSpecificClass, checked: @state.assigned})
        if data.edit_url?
          (a {className: 'mb-edit', href: data.edit_url,  title: 'Edit this activity'},
            (span {className: 'mb-edit-text'}, 'Edit')
          )
        if data.copy_url?
          (a {className: 'mb-copy', href: data.copy_url,  title: 'Make your own version of this activity'},
            (span {className: 'mb-copy-text'}, 'Copy')
          )
        if @hasShortDescription()
          (a {className: 'mb-toggle-info', href: '', onClick: @toggleDescription, title: 'View activity description'},
            (span {className: 'mb-toggle-info-text'}, 'Info')
          )
        if data.preview_url?
          (a {className: 'mb-run', href: data.preview_url,  title: 'Run this activity in the browser'},
            (span {className: 'mb-run-text'}, 'Run')
          )
        if not @props.assignToSpecificClass and data.assign_to_class_url?
          (a {className: 'mb-assign-to-class', href: data.assign_to_class_url, onClick: @assignToClass, title: 'Assign this activity to a class'},
            (span {className: 'mb-assign-to-class-text'}, 'Assign or Share')
          )
        if data.assign_to_collection_url?
          (a {className: 'mb-assign-to-collection', href: data.assign_to_collection_url, onClick: @assignToCollection, title: 'Assign this activity to a collection'},
            (span {className: 'mb-assign-to-collection-text'}, 'Assign to collection')
          )
      )
      (span {className: 'mb-material-name'}, data.name)
      if data.archive_url?
        (a {className: 'mb-archive-link', onClick: @archive, title: "archive this" }, "(archive this)")
      if @hasShortDescription()
        (MBMaterialDescription
          description: data.short_description
          visible: @state.descriptionVisible
        )
    )

window.MBMaterial = React.createFactory MBMaterialClass

# Helper components:

MBMaterialDescription = React.createFactory React.createClass
  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

  render: ->
    (div
      className: "mb-material-description #{@getVisibilityClass()}"
      # It's already sanitized by server!
      dangerouslySetInnerHTML: {__html: @props.description}
    )

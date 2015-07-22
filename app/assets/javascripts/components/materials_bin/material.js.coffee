{div, span, a} = React.DOM

window.MBMaterialClass = React.createClass
  getInitialState: ->
    {
      descriptionVisible: false
    }

  toggleDescription: (e) ->
    @setState descriptionVisible: not @state.descriptionVisible
    e.preventDefault()

  assignToClass: (e) ->
    Portal.assignMaterialToClass @props.material.id, @props.material.class_name
    e.preventDefault()

  assignToCollection: (e) ->
    Portal.assignMaterialToCollection @props.material.id, @props.material.class_name
    e.preventDefault()

  hasDescription: ->
    @props.material.description? && @props.material.description != ''

  render: ->
    data = @props.material
    (div {className: 'mb-material'},
      (span {className: 'mb-material-links'},
        if data.edit_url?
          (a {className: 'mb-edit', href: data.edit_url, target: '_blank', title: 'Edit this activity'},
            (span {className: 'mb-edit-text'}, 'Edit')
          )
        if data.copy_url?
          (a {className: 'mb-copy', href: data.copy_url, target: '_blank', title: 'Make your own version of this activity'},
            (span {className: 'mb-copy-text'}, 'Copy')
          )
        if @hasDescription()
          (a {className: 'mb-toggle-info', href: '', onClick: @toggleDescription, title: 'View activity description'},
            (span {className: 'mb-toggle-info-text'}, 'Info')
          )
        if data.preview_url?
          (a {className: 'mb-run', href: data.preview_url, target: '_blank', title: 'Run this activity in the browser'},
            (span {className: 'mb-run-text'}, 'Run')
          )
        if data.assign_to_class_url?
          (a {className: 'mb-assign-to-class', href: data.assign_to_class_url, onClick: @assignToClass, title: 'Assign this activity to a class'},
            (span {className: 'mb-assign-to-class-text'}, 'Assign to class')
          )
        if data.assign_to_collection_url?
          (a {className: 'mb-assign-to-collection', href: data.assign_to_collection_url, onClick: @assignToCollection, title: 'Assign this activity to a collection'},
            (span {className: 'mb-assign-to-collection-text'}, 'Assign to collection')
          )
      )
      (span {className: 'mb-material-name'}, data.name)
      if @hasDescription()
        (MBMaterialDescription
          description: data.description
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

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
        if @hasDescription()
          (a {className: 'mb-toggle-info', href: '', onClick: @toggleDescription},
            (span {className: 'mb-toggle-info-text'}, 'Info')
          )
        if data.preview_url?
          (a {className: 'mb-run', href: data.preview_url, target: '_blank'},
            (span {className: 'mb-run-text'}, 'Run')
          )
        if Portal.currentUser.isTeacher
          (a {className: 'mb-assign-to-class', href: '', onClick: @assignToClass},
            (span {className: 'mb-assign-to-class-text'}, 'Assign to class')
          )
        if Portal.currentUser.isAdmin
          (a {className: 'mb-assign-to-collection', href: '', onClick: @assignToCollection},
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

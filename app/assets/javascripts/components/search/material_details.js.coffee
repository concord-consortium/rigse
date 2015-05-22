{div, li, i, h3, h4} = React.DOM

window.SMaterialDetailsClass = React.createClass
  toggle: (event) ->
    window.toggleDetails jQuery(event.target)

  toggleFromChild: (event) ->
    window.toggleDetails jQuery(event.target.parentElement)

  hasActivitiesOrPretest: ->
    @props.material.has_activities || @props.material.has_pretest

  getMaterialDescClass: ->
    "material-description #{if @hasActivitiesOrPretest() then 'two-cols' else 'one-col'}"

  renderActivities: ->
    activities = (@props.material.activities || []).map (activity) ->
      (li {key: activity.id}, activity.name) if activity?

  render: ->
    material = @props.material
    (div {className: 'toggle-details', onClick: @toggle},
      (i {className: 'toggle-details-icon fa fa-chevron-down', onClick: @toggleFromChild})
      (i {className: 'toggle-details-icon fa fa-chevron-up', style: {display: 'none'}, onClick: @toggleFromChild})
      (div {className: 'material-details', style: {display: 'none'}},
        (div {className: @getMaterialDescClass()},
          (h3 {}, 'Description')
          # It's already sanitized by server!
          (div {dangerouslySetInnerHTML: {__html: material.description}})
        )
        (div {className: 'material-activities'},
          if material.has_pretest
            (h4 {}, 'Pre- and Post-tests available.')
          if material.activities.length > 0
            (div {},
              (h3 {}, 'Activities')
              @renderActivities()
            )
        )
      )
    )

window.SMaterialDetails = React.createFactory SMaterialDetailsClass

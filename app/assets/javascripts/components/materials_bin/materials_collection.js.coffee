Material = React.createFactory require 'components/materials_bin/material'

{div, a} = React.DOM

module.exports = React.createClass
  renderTeacherGuide: ->
    if Portal.currentUser.isTeacher and @props.teacherGuideUrl?
      (a {href: @props.teacherGuideUrl, target: '_blank'}, 'Teacher Guide')

  render: ->
    (div {className: 'mb-collection'},
      (div {className: 'mb-collection-name'}, @props.name)
      @renderTeacherGuide()
      for material in @props.materials or []
        (Material key: "#{material.class_name}#{material.id}", material: material)
    )

{div, p} = React.DOM

modulejs.define 'components/signup/student_form_sideinfo', [], () ->
  React.createClass
    render: ->
      (div {},
        (p {},
          'Enter the class word your teacher gave you. If you don\'t know what the class word is, ask your teacher.'
        )
      )

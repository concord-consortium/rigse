{div, p, a} = React.DOM

modulejs.define 'components/signup/teacher_registration_complete', [], () ->
  React.createClass
    render: ->
      {anonymous} = @props
      (div {className: 'registration-complete'},
        (p {className: 'reg-header'}, 'Thanks for signing up!')
        if anonymous
          (p {}, 'We\'re sending you an email with your activation code. Click the "Confirm my account" link ' +
                 'in the email to complete the process.')
        else
          (p {}, (a {href: '/'}, 'Start using the site.'))
      )

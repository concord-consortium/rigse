{div, span, p} = React.DOM

modulejs.define 'components/signup/student_registration_complete', [], () ->
  React.createClass
    render: ->
      {first_name, last_name, login} = @props.data
      (div {className: 'registration-complete'},
        (p {className: 'reg-header'}, 'Thanks for signing up!')
        (p {},
          "You have successfully registered #{first_name} #{last_name} with the user name "
          (span {className: 'login'}, login)
          '.'
        )
        (p {}, 'Use this user name and password you provided to sign in.')
      )

{div, span, p, a} = React.DOM

modulejs.define 'components/signup/student_registration_complete', [], () ->
  React.createClass
    render: ->
      {anonymous, data} = @props
      {first_name, last_name, login} = data
      (div {className: 'registration-complete'},
        (p {className: 'reg-header'}, 'Thanks for signing up!')
        if anonymous
          (div {},
            (p {},
              "You have successfully registered #{first_name} #{last_name} with the user name "
              (span {className: 'login'}, login)
              '.'
            )
            (p {}, 'Use this user name and password you provided to sign in.')
          )
        else
          (p {}, (a {href: '/'}, 'Start using the site.'))
      )

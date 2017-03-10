{div, span, p, a} = React.DOM

modulejs.define 'components/signup/student_registration_complete', [], () ->
  React.createClass
    render: ->
      {anonymous, data} = @props
      {first_name, last_name, login} = data
      (div {className: 'registration-complete student'},
        if anonymous
          (div {},
            (p {},
              'Success! Your username is: '
              (span {className: 'login'}, login)
            )
            (p {},
              'Use your new account to sign in here '
              (span {className: 'arrow'}, String.fromCharCode(0x2192))
            )
          )
        else
          (p {}, (a {href: '/'}, 'Start using the site.'))
      )

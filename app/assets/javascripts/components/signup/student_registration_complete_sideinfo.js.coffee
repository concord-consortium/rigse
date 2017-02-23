{div, dd, dt, dl, form, input} = React.DOM

modulejs.define 'components/signup/student_registration_complete_sideinfo', [], () ->
  React.createClass
    render: ->
      (div {},
        (div {className: 'side-info-header'}, 'Sign In')
        (form {method: 'post', action: '/users/sign_in', className: 'ng-pristine ng-valid'},
          (dl {},
            (dt {},
              'Username'
            )
            (dd {},
              (input {name: 'user[login]'})
            )
            (dt {},
              'Password'
            )
            (dd {},
              (input {type: 'password', name: 'user[password]'})
            )
          )
          (input {className: 'button', type: 'submit', value: 'Log In'})
        )
      )

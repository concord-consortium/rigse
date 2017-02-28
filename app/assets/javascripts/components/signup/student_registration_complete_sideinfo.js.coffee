{div, dd, dt, dl, form, input} = React.DOM

modulejs.define 'components/signup/student_registration_complete_sideinfo', [], () ->
  React.createClass
    componentDidMount: ->
      authToken = jQuery('meta[name="csrf-token"]').attr('content');
      jQuery('form[method="post"]').each () ->
        $form = jQuery(this)
        hiddenField = "<input type='hidden' name='authenticity_token' value='#{authToken}'/>"
        if ($form.find('input[name="authenticity_token"]').length is 0)
          $form.prepend(hiddenField)
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

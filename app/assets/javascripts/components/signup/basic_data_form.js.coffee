{button, div} = React.DOM

PASS_TOO_SHORT = 'Password is too short'
PASS_NOT_MATCH = 'Passwords do not match'

modulejs.define 'components/signup/basic_data_form',
[
  'components/signup/text_input',
  'components/signup/radio_input'
],
(
  TextInputClass,
  RadioInputClass
) ->
  TextInput = React.createFactory TextInputClass
  RadioInput = React.createFactory RadioInputClass
  FormsyForm = React.createFactory Formsy.Form

  React.createClass
    displayName: 'BasicDataForm'
    getInitialState: ->
      canSubmit: false
      password: ''

    enableButton: ->
      @setState canSubmit: true

    disableButton: ->
      @setState canSubmit: false

    onChange: (model) ->
      @setState password: model.password

    submit: (model) ->
      @props.onSubmit(model)

    render: ->
      {anonymous} = @props
      (FormsyForm {onValidSubmit: @submit, onValid: @enableButton, onInvalid: @disableButton, onChange: @onChange},
        if anonymous
          (div {},
            (TextInput
              name: 'first_name'
              placeholder: 'First Name'
              required: true
            )
            (TextInput
              name: 'last_name'
              placeholder: 'Last Name'
              required: true
            )
            (TextInput
              name: 'password'
              placeholder: 'Password'
              type: 'password'
              required: true
              validations: 'minLength:6'
              validationError: PASS_TOO_SHORT
            )
            (TextInput
              name: 'password_confirmation'
              placeholder: 'Confirm Password'
              type: 'password'
              required: true
              validations: "equals:#{@state.password}"
              validationError: PASS_NOT_MATCH
            )
          )
        (RadioInput
          name: 'type'
          title: 'I am a '
          required: true
          options: [
            {label: 'Teacher', value: 'teacher'}
            {label: 'Student', value: 'student'}
          ]
        )
        (button {className: 'submit-btn', type: 'submit', disabled: !@state.canSubmit}, @props.signupText)
      )

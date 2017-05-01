{button, div} = React.DOM

PASS_TOO_SHORT      = 'Password is too short'
PASS_NOT_MATCH      = 'Passwords do not match'
INVALID_FIRST_NAME  = 'Invalid first name. Use only letters and numbers.'
INVALID_LAST_NAME   = 'Invalid last name. Use only letters and numbers.'

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
  
  nameValidator = (value) ->
      jQuery.get "#{Portal.API_V1.NAME_VALID}?name=#{value}"


  React.createClass
    getInitialState: ->
      canSubmit: false
      password: ''

    enableButton: ->
      @setState canSubmit: true

    disableButton: ->
      @setState canSubmit: false

    onChange: (model) ->
      @setState password: model.password

    onBasicFormValid: ->
      @setState canSubmit:  (   @refs.firstName.isValidAsync() &&
                                @refs.lastName.isValidAsync()       )

    onBasicFormInvalid: ->
      @setState canSubmit: false

    submit: (model) ->
      @props.onSubmit(model)

    render: ->
      {anonymous} = @props
      (FormsyForm { onValidSubmit: @submit, onValid: @onBasicFormValid, onInvalid: @onBasicFormInvalid, onChange: @onChange },
        if anonymous
          (div { },
            (div { className: 'name_wrapper' },
              (TextInput
                ref:  'firstName'
                name: 'first_name'
                placeholder: 'First Name'
                required: true
                asyncValidation: nameValidator
                asyncValidationError: INVALID_FIRST_NAME
              )
            )
            (div { className: 'name_wrapper' },
              (TextInput
                ref:  'lastName'
                name: 'last_name'
                placeholder: 'Last Name'
                required: true
                asyncValidation: nameValidator
                asyncValidationError: INVALID_LAST_NAME
              )
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

{button, div} = React.DOM
INVALID_CLASS_WORD = 'You must enter a valid class word'

modulejs.define 'components/signup/student_form',
[
  'components/signup/text_input',
  'components/signup/privacy_policy'
],
(
  TextInputClass,
  PrivacyPolicyClass
) ->
  TextInput = React.createFactory TextInputClass
  PrivacyPolicy = React.createFactory PrivacyPolicyClass
  FormsyForm = React.createFactory Formsy.Form

  classWordValidator = (value) ->
    jQuery.get "#{Portal.API_V1.CLASSWORD}?class_word=#{value}"

  registerStudent = (params) ->
    jQuery.post Portal.API_V1.STUDENTS, params

  React.createClass
    getInitialState: ->
      canSubmit: false

    onBasicFormValid: ->
      # Unfortunately, async validation is not respected by onValid / onInvalid handlers. We need to manually check
      # async components.
      @setState canSubmit: @refs.classWord.isValidAsync()

    onBasicFormInvalid: ->
      @setState canSubmit: false
    
    submit: (data, resetForm, invalidateForm) ->
      {basicData, onRegistration} = @props
      params = jQuery.extend {}, basicData, data
      @setState canSubmit: false
      registerStudent(params)
        .done (data) ->
          onRegistration(data)
        .fail (err) ->
          serverErrors = JSON.parse(err.responseText).message
          invalidateForm serverErrors

    render: ->
      {canSubmit} = @state
      (FormsyForm {ref: 'form', onValidSubmit: @submit, onValid: @onBasicFormValid, onInvalid: @onBasicFormInvalid},
        (TextInput
          ref: 'classWord'
          name: 'class_word'
          placeholder: 'Class Word (not case sensitive)'
          required: true
          asyncValidation: classWordValidator
          asyncValidationError: INVALID_CLASS_WORD
        )
        (PrivacyPolicy {})
        (button {className: 'submit-btn', type: 'submit', disabled: !canSubmit}, 'Sign Up!')
      )

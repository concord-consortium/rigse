{button, a, i, div} = React.DOM
LOGIN_TOO_SHORT = 'Login is too short'
LOGIN_TAKEN = 'That login is taken'
LOGIN_REGEXP = 'Use only letters, numbers, and +.-_@ please'
EMAIL_REGEXP = 'Email doesn\'t appear to be a valid email'
EMAIL_TAKEN = 'Email belongs to an existing user'
CANT_FIND_SCHOOL = 'I can\'t find my school in the list.'
GO_BACK_TO_LIST = 'Go back to the school list.'
newSchoolWarning = (zipOrPostal) ->
  'You are adding a new school / institution. Please make sure that the ' +
  "#{zipOrPostal} and school / institution name are correct!"
zipcodeHelp = (zipOrPostal) ->
  "Not sure which #{zipOrPostal} to use? Please enter the #{zipOrPostal} of your school's address."
invalidZipcode = (zipOrPostal) ->
  "Incorrect #{zipOrPostal}"

modulejs.define 'components/signup/teacher_form',
[
  'components/signup/text_input',
  'components/signup/select_input',
  'components/signup/school_input',
  'components/signup/privacy_policy'
],
(
  TextInputClass,
  SelectInputClass,
  SchoolInputClass,
  PrivacyPolicyClass
) ->
  TextInput = React.createFactory TextInputClass
  SelectInput = React.createFactory SelectInputClass
  SchoolInput = React.createFactory SchoolInputClass
  PrivacyPolicy = React.createFactory PrivacyPolicyClass
  FormsyForm = React.createFactory Formsy.Form

  loginAvailableValidator = (value) ->
    jQuery.get "#{Portal.API_V1.LOGINS}?username=#{value}"

  emailAvailableValidator = (value) ->
    jQuery.get "#{Portal.API_V1.EMAILS}?email=#{value}"

  getCountries = ->
    jQuery.get(Portal.API_V1.COUNTRIES)

  registerTeacher = (params) ->
    jQuery.post Portal.API_V1.TEACHERS, params

  isUS = (name) ->
    name == 'United States' || name == 'US' || name == 'USA'

  React.createClass
    getInitialState: ->
      canSubmit: false
      currentCountry: null
      currentZipcode: null
      isUSSelected: false
      registerNewSchool: false
      showZipcodeHelp: false

    onBasicFormValid: ->
      # Unfortunately, async validation is not respected by onValid / onInvalid handlers. We need to manually check
      # async components. Note that they might be undefined in non-anonymous mode.
      valid = true
      if @refs.login && !@refs.login.isValidAsync()
        valid = false
      if @refs.email && !@refs.email.isValidAsync()
        valid = false
      @setState canSubmit: valid

    onBasicFormInvalid: ->
      @setState canSubmit: false
    
    submit: (data, resetForm, invalidateForm) ->
      {basicData, onRegistration} = @props
      params = jQuery.extend {}, basicData, data
      @setState canSubmit: false
      registerTeacher(params)
        .done (data) ->
          onRegistration(data)
        .fail (err) ->
          serverErrors = JSON.parse(err.responseText).message
          invalidateForm serverErrors

    onChange: (currentValues) ->
      {country_id, zipcode} = currentValues
      {currentZipcode, registerNewSchool} = @state
      zipcodeValid = @refs.zipcode && @refs.zipcode.isValidValue zipcode
      @setState
        currentCountry: country_id
        currentZipcode: zipcodeValid && zipcode || null
        # Go back to school list each time zip code is changed, so user has chance to find his school.
        registerNewSchool: registerNewSchool && zipcode == currentZipcode

    getCountries: (input, callback) ->
      getCountries().done (data) ->
        callback null, {
          options: data.map (country) -> label: country.name, value: country.id
          complete: true
        }
      # Do not return jQuery.Deffered as that confuses react-select component.
      undefined

    addNewSchool: ->
      @setState registerNewSchool: true

    goBackToSchoolList: ->
      @setState registerNewSchool: false

    showZipcodeHelp: ->
      @setState showZipcodeHelp: true

    checkIfUS: (option) ->
      @setState isUSSelected: isUS(option.label)

    zipcodeValidation: (values, value) ->
      {isUSSelected} = @state
      return true unless isUSSelected
      value && value.match /\d{5}/ # 5 digits

    zipOrPostal: ->
      {isUSSelected} = @state
      if isUSSelected then 'ZIP code' else 'postal code'

    render: ->
      {anonymous} = @props
      {canSubmit, currentCountry, currentZipcode, registerNewSchool, showZipcodeHelp} = @state
      showZipcode = currentCountry?
      showSchool = currentCountry? && currentZipcode?
      (FormsyForm {ref: 'form', onValidSubmit: @submit, onValid: @onBasicFormValid, onInvalid: @onBasicFormInvalid, onChange: @onChange},
        if anonymous
          (div {},
            (TextInput
              ref: 'login'
              name: 'login'
              placeholder: 'Username'
              required: true
              validations:
                minLength: 3
                matchRegexp: /^[a-zA-Z0-9\.\+\-\_\@]*$/
              validationErrors:
                minLength: LOGIN_TOO_SHORT
                matchRegexp: LOGIN_REGEXP
              asyncValidation: loginAvailableValidator
              asyncValidationError: LOGIN_TAKEN
            )
            (TextInput
              ref: 'email'
              name: 'email'
              placeholder: 'Email'
              required: true
              validations:
                isEmail: true
              validationErrors:
                isEmail: EMAIL_REGEXP
              asyncValidation: emailAvailableValidator
              asyncValidationError: EMAIL_TAKEN
            )
          )
        (SelectInput
          name: 'country_id'
          placeholder: 'Country'
          loadOptions: @getCountries
          required: true
          onChange: @checkIfUS
        )
        if showZipcode
          (div {},
            (TextInput
              ref: 'zipcode'
              name: 'zipcode'
              placeholder: "School / Institution #{@zipOrPostal()}"
              required: true
              validations:
                zipcode: @zipcodeValidation
              validationErrors:
                zipcode: invalidZipcode(@zipOrPostal())
              # Ignore whitespace in zip code.
              processValue: (val) -> val.replace /\s/g, ''
            )
            if !showZipcodeHelp
              (i {className: 'zipcode-help-icon fa fa-question-circle', onClick: @showZipcodeHelp})
            if showZipcodeHelp
              (div {className: 'help-text'},
                (div {}, zipcodeHelp(@zipOrPostal()))
              )
          )
        if showSchool && !registerNewSchool
          (SchoolInput
            name: 'school_id'
            placeholder: 'School / Institution'
            country: currentCountry
            zipcode: currentZipcode
            onAddNewSchool: @addNewSchool
            required: true
          )
        if showSchool && !registerNewSchool
          (a {onClick: @addNewSchool}, CANT_FIND_SCHOOL)
        if showSchool && registerNewSchool
          (div {},
            (TextInput
              name: 'school_name'
              placeholder: 'School / Institution Name'
              required: true
            )
            (div {className: 'help-text'}, newSchoolWarning(@zipOrPostal()))
          )
        if showSchool && registerNewSchool
          (a {onClick: @goBackToSchoolList}, GO_BACK_TO_LIST)
        (PrivacyPolicy {})
        (button {className: 'submit-btn', type: 'submit', disabled: !canSubmit}, 'Sign Up!')
      )

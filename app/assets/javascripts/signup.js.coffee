(($) ->

  class SignupForm
    constructor: (@selector) ->
      @$form = $(@selector)
      @accountType = null
      @unknownSchool = false

      @setupSelectBoxes()
      @setupSecurityQuestions()
      @setupSchoolSelect()
      @setupNewSchoolLinks()
      @setupFormButtons()

    validateBasicFields: ->
      valid = true

      if @field('first_name').val().length < 1
        @showErrors first_name: 'Enter first name'
        valid = false

      if @field('last_name').val().length < 1
        @showErrors last_name: 'Enter last name'
        valid = false

      pass = @field('password').val()
      if pass.length < 6
        @showErrors password: 'Password is too short'
        valid = false

      if pass != @field('password_confirmation').val()
        @showErrors password_confirmation: 'Passwords must match'
        valid = false

      return valid

    processTeacherErrors: (errors) ->
      # Note that if field is hidden, it means that user never selected
      # previous field in state - district - school sequence.
      if errors.school_id && @field('district_id').hasClass 'hidden'
        errors.state = 'Please select a state'
        delete errors.school_id
      else if  errors.school_id && @field('school_id').hasClass 'hidden'
        errors.district_id = 'Please select a district'
        delete errors.school_id

    serializeAndSubmit: ->
      if @isStudent()
        url = API_V1.STUDENTS
      else
        url = API_V1.TEACHERS

      # wait_message.js
      @el('.submit-form').prop 'disabled', true
      startWaiting 'Please wait while your account is created'


      $.ajax(
        type: 'post'
        url: url
        contentType: 'application/json'
        data: @toJSON()
      ).done((data) =>
        @$form.empty()
        @$form.append "<div class='success'>#{@welcomeMessage(data)}<div>"
        @field('submit')
      ).fail((jqXHR) =>
        errors = JSON.parse(jqXHR.responseText).message
        @showErrors(errors)
      ).always( =>
        stopWaiting()
        @el('.submit-form').prop 'disabled', false
      )

    toJSON: ->
      data = @$form.serializeObject()
      delete data.school_name unless @unknownSchool
      JSON.stringify(data)

    showErrors: (errors) ->
      @clearErrors()
      @processTeacherErrors(errors) if @isTeacher()

      for fieldName, error of errors
        indexedError = fieldName.match(/(.+)\[(\d+)\]/)
        if indexedError
          # Support errors defined per array element, e.g.: { question[2]: "You have to provide 3 questions!" }
          # We have an assumption that fields definiting an array have name with
          # brackets (e.g. question[]). So we have to parse number and select nth field.
          fieldName = indexedError[1] + "[]"
          elIndex = Number(indexedError[2])
          $f = @field(fieldName).eq(elIndex)
        else
          $f = @field(fieldName)

        $f = $f.parent()
        $f.addClass 'error-field'
        $f.prepend "<div class=\"error-message\">#{error}</div>"

    clearErrors: ->
      @$form.find('.error-field').removeClass 'error-field'
      @$form.find('.error-message').remove()

    clearFieldErrors: (fieldName) ->
      $fieldParent = @field(fieldName).parent()
      $fieldParent.removeClass 'error-field'
      $fieldParent.find('.error-message').remove()

    setupSelectBoxes: ->
      @el('select').select2(width: "267px", minimumResultsForSearch: 10)

    setupSecurityQuestions: ->
      @field('questions[]').getSelectOptions API_V1.SECURITY_QUESTIONS, (data) ->
        data.unshift undefined # we need an empty option for placeholder
        {val: t, text: t} for t in data

    setupSchoolSelect: ->
      state = @field('state')
      district_id = @field('district_id')
      school_id = @field('school_id')

      state.getSelectOptions API_V1.STATES, (data) ->
        data.unshift undefined # we need an empty option for placeholder
        {val: s, text: s} for s in data

      state.on 'change', =>
        return if state.val() == ''
        district_id.getSelectOptions API_V1.DISTRICTS + "?state=#{state.val()}", (data) ->
          data.unshift {} # we need an empty option for placeholder
          {val: d.id, text: d.name} for d in data
        , ->
          district_id.removeClass 'hidden'

      district_id.on 'change', =>
        return if district_id.val() == ''
        school_id.getSelectOptions API_V1.SCHOOLS + "?district_id=#{district_id.val()}", (data) ->
          data.unshift {} # we need an empty option for placeholder
          {val: s.id, text: s.name} for s in data
        , =>
          school_id.removeClass 'hidden'
          @el('#custom-name').removeClass 'hidden'

    setupNewSchoolLinks: ->
      @el('#custom-name, #no-custom-name').on 'click', =>
        @switchSchoolSelect()

    setupFormButtons: ->
      @el('#continue-registration').on 'click', (e) =>
        e.preventDefault()
        @clearErrors()
        return unless @validateBasicFields()
        @el('#common-fieldset').addClass 'hidden'

        if @el('#student_account').is(':checked')
          @el('#student-fieldset').removeClass 'hidden'
          @accountType = 'student'
        else
          @el('#teacher-fieldset').removeClass 'hidden'
          @accountType = 'teacher'

      @el('.submit-form').on 'click', (e) =>
        e.preventDefault()
        @serializeAndSubmit()

    isStudent: ->
      @accountType == 'student'

    isTeacher: ->
      @accountType == 'teacher'

    switchSchoolSelect: ->
      @field('school_name').toggleClass 'hidden'
      @field('school_id').toggleClass 'hidden'
      @el('#no-custom-name').toggleClass 'hidden'
      @el('#custom-name').toggleClass 'hidden'
      @field('school_id').select2 'val', ''
      @field('school_name').val ''
      @clearFieldErrors 'school_id'
      @clearFieldErrors 'school_name'

      @unknownSchool = !@unknownSchool

    welcomeMessage: (data) ->
      if @isStudent()
        "<h3>Thanks for signing up!</h3>" +
        "<p>You have successfully registered #{data.first_name} #{data.last_name} " +
        " with the user name <span class=\"big\">#{data.login}</span>.</p>" +
        "Use this user name and password you provided to sign in.</p>"
      else
        "<h3>Thanks for signing up!</h3>" +
        "<p>We're sending you an email with your activation code.</p>"

    field: (name) ->
      @$form.find "input[name=\"#{name}\"], select[name=\"#{name}\"]"

    el: (selector) ->
      @$form.find selector

  $ ->
    new SignupForm('#new-account-form')

)(jQuery)

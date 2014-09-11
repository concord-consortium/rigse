(($) ->

  class SignupForm
    constructor: (@selector) ->
      @$form = $(@selector)

    initializeForms: ->
      @setupSelectBoxes()
      @setupSecurityQuestions()
      @setupSchoolSelect()
      @setupNewSchoolLinks()
      @setupFormButtons()
      @armSubmitHandler()

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

      if !(@isTeacher() || @isStudent())
        @showErrors 'account_type': 'Select account type'
        valid = false

      return valid

    prcessSchoolErrors: (errors) ->
      # Note that if field is hidden, it means that user never selected
      # previous field in state - district - school sequence.
      if $('#custom-school').hasClass 'hidden'
        if errors.school_name
          errors.school_id = "Please select a school"
          delete errors.school_name
          delete errors.city
          delete errors.province
          delete errors.state
      else if @field('district_id').hasClass 'hidden'
        errors.state = 'Please select a state'
        delete errors.school_id
      else if  @field('school_id').hasClass 'hidden'
        errors.district_id = 'Please select a district'
        delete errors.school_id


    serializeAndSubmit: (url)->
      @clearErrors()

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
        errors = null
        try
          errors = JSON.parse(jqXHR.responseText).message
        catch e
          console.log 'Unknown error during sign up'
        finally
          unless typeof errors == 'object'
            errors = 'unknown-error': 'We are sorry, something went wrong. Please reload the page and try again.'
          @showErrors errors
      ).always( =>
        stopWaiting()
        @el('.submit-form').prop 'disabled', false
      )

    toJSON: ->
      data = @$form.serializeObject()
      JSON.stringify(data)

    showErrors: (errors, maxToShow=3) ->
      
      errorCount = 0
      @prcessSchoolErrors(errors)
      debugger
      dispError = ($el, msg) =>
        $el.addClass 'error-field'
        $el.prepend "<div class=\"error-message\">#{msg}</div>"

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
        if (errorCount < maxToShow)
          errorCount = errorCount + 1
          dispError $f.parent(), error

      if errors && errors['unknown-error']
        dispError @el('.unknown-error'), errors['unknown-error']

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
      country_id = @field('country_id')
      state = @field('state')
      district_id = @field('district_id')
      school_id = @field('school_id')

      country_id.getSelectOptions API_V1.COUNTRIES, (data) ->
        {val: c.id, text: c.name} for c in data

      country_id.on 'change', =>
        @clearErrors()
        @hideSchoolPicker()
        @hideCustomSchool()
        district_id.addClass 'hidden'
        state.addClass 'hidden'

        if country_id.val() == API_V1.USA_ID
          @hideInternational()
          state.getSelectOptions API_V1.STATES + "?country=#{country_id.val()}", (data) ->
            data.unshift undefined # we need an empty option for placeholder
            {val: s, text: s} for s in data
          , ->
            state.removeClass 'hidden'

          state.on 'change', =>
            return if state.val() == ''
            district_id.getSelectOptions API_V1.DISTRICTS + "?state=#{state.val()}", (data) ->
              data.unshift {} # we need an empty option for placeholder
              {val: d.id, text: d.name} for d in data
            , =>
              district_id.removeClass 'hidden'

          district_id.on 'change', =>
            return if district_id.val() == ''
            school_id.getSelectOptions API_V1.SCHOOLS + "?district_id=#{district_id.val()}", (data) ->
              data.unshift {} # we need an empty option for placeholder
              {val: s.id, text: s.name} for s in data
            , =>
              @showSchoolPicker()
        else
          @showInternational()
          school_id.getSelectOptions API_V1.SCHOOLS + "?country_id=#{country_id.val()}", (data) ->
            data.unshift {} # we need an empty option for placeholder
            {val: s.id, text: s.name} for s in data
          , =>
            @showSchoolPicker()

    showInternational: ->
      $('.intl-only').removeClass 'hidden'
    
    hideInternational: ->
      $('.intl-only').addClass 'hidden'

    showDomestic: ->
      $('.domestic-only').removeClass 'hidden'
    
    hideDomestic: ->
      $('domestic-only').addClass 'hidden'

    setupNewSchoolLinks: ->
      @el('#cant-find-school').on 'click', =>
        @showCustomSchool()
      @el('#back-to-list').on 'click', =>
        @showSchoolPicker()

    accountType: ->
      $("input[name=account_type]:checked").val()
    
    isStudent: ->
      @accountType() == 'student'

    isTeacher: ->
      @accountType() == 'teacher'

    setupFormButtons: ->
      @el('#continue-registration').on 'click', (e) =>
        e.preventDefault()
        @clearErrors()
        return unless @validateBasicFields()
        if @isStudent()
          @showStudentForm()
        else if @isTeacher()
          @showTeacherForm()

    showStudentForm: ->
      @el('#common-fieldset').addClass 'hidden'
      @el('#student-fieldset').removeClass 'hidden'
      @armSubmitHandler(API_V1.STUDENTS)

    showTeacherForm: ->
      @el('#common-fieldset').addClass 'hidden'
      @el('#teacher-fieldset').removeClass 'hidden'
      @armSubmitHandler(API_V1.TEACHERS)

    armSubmitHandler: (url) ->
      @el('.submit-form').on 'click', (e) =>
        e.preventDefault()
        @serializeAndSubmit(url)

    clearSchoolValues: ->
      @field('school_id').select2 'val', ''
      @field('school_name').val ''

    clearSchoolErrors: ->
      @clearFieldErrors 'school_id'
      @clearFieldErrors 'school_name'

    hideCustomSchool: ->
      $('#custom-school').addClass 'hidden'

    hideSchoolPicker: ->
      $('#school-picker').addClass 'hidden'

    showSchoolPicker: ->
      @clearErrors()
      @clearSchoolValues()
      @el('#school-picker').removeClass 'hidden'
      @hideCustomSchool()

    showCustomSchool: ->
      @clearErrors()
      @clearSchoolValues()
      @el('#custom-school').removeClass 'hidden'
      @hideSchoolPicker()


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

(($) ->

  class SignupForm
    constructor: (@selector) ->
      @$form = $(@selector)
      @field('questions[]').getSelectOptions API_V1.SECURITY_QUESTIONS, (data) ->
        res = []
        data.forEach (t) ->
          res.push val: t, text: t
        res

      @setupSchoolSelect()

      @el('#continue-registration').on 'click', (e) =>
        e.preventDefault()
        @clearErrors()
        return unless @validateBasicFields()
        @el('#common-fieldset').addClass 'hidden'

        if @student()
          @el('#student-fieldset').removeClass 'hidden'
        else
          @el('#teacher-fieldset').removeClass 'hidden'

      @el('.submit-form').on 'click', (e) =>
        e.preventDefault()
        @clearErrors()
        @serializeAndSubmit()

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
      if @field('district').hasClass 'hidden'
        errors.state = 'Please select a state'
        delete errors.school_id
      else if @field('school_id').hasClass 'hidden'
        errors.district = 'Please select a district'
        delete errors.school_id

    serializeAndSubmit: ->
      if @student()
        url = API_V1.STUDENTS
      else
        url = API_V1.TEACHERS

      $.ajax(
        type: 'post'
        url: url
        contentType: 'application/json'
        data: @$form.serializeJSON()
      ).done((data) =>
        @$form.empty()
        @$form.append "<div class='success'>#{@welcomeMessage()}<div>"
      ).fail((jqXHR) =>
        errors = JSON.parse(jqXHR.responseText).message
        @showErrors(errors)
      )

    showErrors: (errors) ->
      @processTeacherErrors(errors) if @teacher

      for fieldName, error of errors
        $f = @field(fieldName).parent()
        $f.addClass 'error-field'
        $f.prepend "<p class=\"error-message\">#{error}</p>"

    clearErrors: ->
      @$form.find('.error-field').removeClass 'error-field'
      @$form.find('.error-message').remove()

    setupSchoolSelect: ->
      state = @field('state')
      district = @field('district')
      school_id = @field('school_id')

      state.getSelectOptions API_V1.STATES, (data) ->
        res = [{val: '', text: '- Select a state'}]
        data.forEach (s) ->
          res.push val: s, text: s
        res
      , ->
        state.trigger 'change'

      state.on 'change', =>
        return if state.val() == ''
        district.getSelectOptions API_V1.DISTRICTS + "?state=#{state.val()}", (data) ->
          res = [{val: '', text: '- Select a district'}]
          data.forEach (d) ->
            res.push val: d.id, text: d.name
          res
        , ->
          district.removeClass 'hidden'
          district.trigger 'change'

      district.on 'change', =>
        return if district.val() == ''
        school_id.getSelectOptions API_V1.SCHOOLS + "?district_id=#{district.val()}", (data) ->
          res = [{val: '', text: '- Select a school'}]
          data.forEach (s) ->
            res.push val: s.id, text: s.name
          res
        , ->
          school_id.removeClass 'hidden'

    student: ->
      @el('#student_account').is(':checked')

    teacher: ->
      !@student

    welcomeMessage: ->
      if @student()
        "<h3>Thanks for signing up!</h3>" +
        "<p>You have successfully registered #{data.first_name} #{data.last_name} " +
        " with the user name <span class=\"big\">#{data.username}</span>.</p>" +
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

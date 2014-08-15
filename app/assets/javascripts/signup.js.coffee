(($, proto) ->

  class SignupForm
    constructor: (@selector) ->
      @$form = $(@selector)
      @field('questions[]').getSelectOptions '/api/v1/security_questions', (data) ->
        res = []
        data.forEach (t) ->
          res.push val: t, text: t
        res

      @el('#continue-registration').on 'click', (e) =>
        e.preventDefault()
        @clearErrors()
        return unless @validateBasicFields()
        @el('#common-fieldset').addClass 'hidden'
        @el('#student-fieldset').removeClass 'hidden'

      @el('#submit-form').on 'click', (e) =>
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

    serializeAndSubmit: ->
      $.ajax(
        type: 'post'
        url: '/api/v1/students'
        contentType: 'application/json'
        data: @$form.serializeJSON()
      ).done((data) =>
        @showWelcomeMessage(data)
      ).fail((jqXHR) =>
        errors = JSON.parse(jqXHR.responseText).message
        @showErrors(errors)
      )

    showWelcomeMessage: (data) ->
      @$form.empty()
      @$form.append "<div class='success'>You have successfully registered #{data.first_name} #{data.last_name} " +
                    " with the username <span class=\"big\">#{data.username}</span>.<div>"

    showErrors: (errors) ->
      for fieldName, error of errors
        $f = @field(fieldName)
        $f.addClass 'error-field'
        $f.parent().prepend "<p class=\"error-message\">#{error}<p>"

    clearErrors: ->
      @$form.find('.error-field').removeClass 'error-field'
      @$form.find('.error-message').remove()

    field: (name) ->
      @$form.find "input[name=\"#{name}\"], select[name=\"#{name}\"]"

    el: (selector) ->
      @$form.find selector

  $ ->
    window.t = new SignupForm('#new-account-form')

)(jQuery, $)

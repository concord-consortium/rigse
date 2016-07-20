{div, input} = React.DOM

# This mixin is a bic hacky. It's not easy to come up with reasonable solution for async validation
# using Formsy. There are some examples, but they perform validation on submit.
# This mixin provides .validateAsync() method that can be called whenever needed, e.g. in onChange handler.
# It also provides .isValidAsync() which is extension of a basic .isValid() but takes async validation into account.

modulejs.define 'components/signup/async_validation_mixin', [], () ->
  getInitialState: ->
    _asyncValidationPassed: true

  getDefaultProps: ->
    asyncValidationTimeout: 500
    asyncValidationError: 'Async validation failed'

  isValidAsync: ->
    @isValid() && @state._asyncValidationPassed

  validateAsync: (value) ->
    return unless @props.asyncValidation

    @setState _asyncValidationPassed: false
    clearTimeout(@_asyncValidationTimeoutID) if @_asyncValidationTimeoutID
    @_asyncValidationTimeoutID = setTimeout =>
      # asyncValidation function is expected to return jQuery.Deferred or any object that follows its API.
      @props.asyncValidation(value)
        .done(=>
          @setState _asyncValidationPassed: true
          # Rerun validation manually so the form runs validation again and triggers .onValid or .onInvalid handlers.
          # It's useful together with .isValidAsync() method.
          @context.formsy.validate(this)
        )
        .fail(=>
          # Use Formsy internal state defined in Forsmy.Mixin. Not very nice, but the simplest solution.
          # Take a look at Formsy updateInputsWithError function.
          @setState _asyncValidationPassed: false, _isValid: false, _externalError: [@props.asyncValidationError]
        )
    , @props.asyncValidationTimeout

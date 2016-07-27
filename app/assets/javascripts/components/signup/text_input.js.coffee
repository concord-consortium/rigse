{div, input} = React.DOM
TIMEOUT = 350

modulejs.define 'components/signup/text_input',
[
  'components/signup/async_validation_mixin'
],
(
  AsyncValidationMixin
) ->
  React.createClass
    mixins: [Formsy.Mixin, AsyncValidationMixin]

    getDefaultProps: ->
      type: 'text'

    getInitialState: ->
      inputVal: ''

    onChange: (event) ->
      {processValue} = @props
      newVal = event.currentTarget.value
      @setState inputVal: newVal
      # @setValue runs validations and sets value of the whole input component.
      # Delay validation a bit if some errors are going to be shown. It might be annoying if user is still typing.
      clearTimeout(@timeoutID) if @timeoutID
      delay = if @isValidValue newVal then 0 else TIMEOUT
      @timeoutID = setTimeout =>
        newVal = processValue newVal if processValue
        @setValue newVal
      , delay
      # Trigger async validation (optional), but only if the new value passes basic validations.
      @validateAsync newVal if @isValidValue newVal

    render: ->
      {placeholder, disabled} = @props
      {inputVal} = @state
      # Set a specific className based on the validation state of this component. showRequired() is true
      # when the value is empty and the required prop is passed to the input. showError() is true when the
      # value typed is invalid.
      className = "text-input #{@props.name}"
      className += ' required' if @showRequired() && !@isPristine()
      className += ' error' if @showError()
      className += ' valid' if @isValidAsync()
      className += ' disabled' if disabled
      (div {className: className},
        (input {type: @props.type, onChange: @onChange, value: inputVal, placeholder: placeholder, disabled: disabled})
        (div {className: 'input-error'}, @getErrorMessage())
      )

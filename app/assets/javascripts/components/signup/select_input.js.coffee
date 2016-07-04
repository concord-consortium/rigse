{div, input, label} = React.DOM

modulejs.define 'components/signup/select_input', [], () ->
  # Select is a React component provided by react-submit library.
  SelectAsync = React.createFactory Select.Async

  React.createClass
    mixins: [Formsy.Mixin]

    # setValue() will set the value of the component, which in
    # turn will validate it and the rest of the form.
    changeValue: (option) ->
      @setValue option && option.value
      @props.onChange option

    render: ->
      {placeholder, loadOptions, disabled} = @props
      className = 'select-input'
      className += ' valid' if @getValue()
      (div {className: className},
        (SelectAsync
          placeholder: placeholder
          loadOptions: loadOptions
          disabled: disabled
          value: @getValue() || '',
          onChange: @changeValue
          clearable: false
        )
        (div {className: 'input-error'}, @getErrorMessage())
      )

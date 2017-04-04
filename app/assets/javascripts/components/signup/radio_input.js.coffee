{div, input, label} = React.DOM

modulejs.define 'components/signup/radio_input', [], () ->
  React.createClass
    displayName: 'RadioInput'
    mixins: [Formsy.Mixin]

    # setValue() will set the value of the component, which in
    # turn will validate it and the rest of the form.
    changeValue: (event) ->
      @setValue event.currentTarget.value

    render: ->
      (div {className: 'radio-input'},
        @props.title
        for option in @props.options
          (label {key: option.value},
            option.label
            (input {type: 'radio', onChange: @changeValue, value: option.value, checked: @getValue() == option.value})
          )
      )

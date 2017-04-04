{div, input, a, label} = React.DOM
TIMEOUT = 500

modulejs.define 'components/signup/school_input', [], () ->
  # Select is a React component provided by react-submit library.
  ReactSelect = React.createFactory Select

  getSchools = (country, zipcode) ->
    jQuery.get("#{Portal.API_V1.SCHOOLS}?country_id=#{country}&zipcode=#{zipcode}")

  React.createClass
    displayName: 'SchoolInput'
    mixins: [Formsy.Mixin]

    getInitialState: ->
      isLoading: false
      options: []

    componentDidMount: ->
      @updateOptions()

    componentDidUpdate: (prevProps) ->
      {country, zipcode} = @props
      # Update options if country is changed or zipcode input is changed.
      if prevProps.country != country || prevProps.zipcode != zipcode
        # Reset current school if country or zipcode is changed and download a new list of schools.
        @setValue ''
        @updateOptions()

    newSchoolLink: ->
      {onAddNewSchool} = @props
      (div {className: 'new-school-link', onClick: onAddNewSchool}, 'Add a new school')

    # setValue() will set the value of the component, which in
    # turn will validate it and the rest of the form.
    changeValue: (option) ->
      @setValue option && option.value

    updateOptions: ->
      {country, zipcode} = @props
      return if !country? || !zipcode?
      clearTimeout @timeoutID if @timeoutID
      @setState isLoading: true
      @timeoutID = setTimeout =>
        getSchools(country, zipcode).done (data) =>
          options = data.map (school) -> label: school.name, value: school.id
          options.push {label: @newSchoolLink(), disabled: true}
          @setState options: options, isLoading: false
      , TIMEOUT

    render: ->
      {placeholder, disabled, onAddNewSchool} = @props
      {options, isLoading} = @state
      className = 'select-input'
      className += ' valid' if @getValue()
      (div {className: className},
        (ReactSelect
          placeholder: placeholder
          options: options
          isLoading: isLoading
          disabled: disabled
          value: @getValue() || ''
          onChange: @changeValue
          clearable: false
          noResultsText:
            (div {},
              (div {}, 'No schools found')
              @newSchoolLink()
            )
        )
        (div {className: 'input-error'}, @getErrorMessage())
      )

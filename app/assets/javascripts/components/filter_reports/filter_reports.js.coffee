{div, span, h3, form, input, i, button} = React.DOM
ReactSelect = React.createFactory Select
DayP = React.createFactory DayPickerOverlay

title = (str) -> (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g," ")

queryCache = {}

queryFormID = "query-form"

window.FilterReports = React.createClass

  getInitialState: ->
    {
      counts: {}
      # the current values of the filters
      schools: []
      teachers: []
      runnables: []
      permission_forms: []
      start_date: ''
      end_date: ''
      hide_names: false
      # all possible values for each pulldown
      filterables: {
        schools: []
        teachers: []
        runnables: []
        permission_forms: []
      }
      # waiting for results
      waitingFor_schools: false
      waitingFor_teachers: false
      waitingFor_runnables: false
      waitingFor_permission_forms: false
    }

  componentWillMount: ->
    @updateFilters()

  # Queries ES using the portal API
  # If we pass a field name, the filter box for that field will *not* be
  # updated, b ut all others will. This lets us find all possible values
  # for a dropdown given all the other filters.
  # If we don't pass a field name, the counts are updates.
  # All requests are cached, and if we make a duplicate request as one that
  # is still pending, the new callback is added as a chained promise, so that
  # no new request is made.
  query: (_params, _fieldName, searchString) ->
    if _fieldName
      @setState {"waitingFor_#{_fieldName}": true}
    params = jQuery.extend({}, _params)     # clone
    if _fieldName
      # we remove the value of each field from the filter query for that
      # dropdown, as we want to know all possible values for that dropdown
      # given only the other filters
      delete params[_fieldName]
    if searchString
      params[_fieldName] = searchString

    cacheKey = JSON.stringify(params)

    handleResponse = ((fieldName) =>
      return (data) =>
        queryCache[cacheKey] = data
        aggs = data.aggregations
        if fieldName
          newState = { filterables: @state.filterables }
          buckets = aggs[fieldName].buckets
          ids_field = "#{fieldName}_ids"
          if aggs[ids_field]
            # some fields have a separate id aggregration that is filtered
            # based on the access of the current user
            # we use this to filter the buckets in the main field aggregration
            filtered_ids = aggs[ids_field].buckets.map( (b) ->
              # sometimes this will be an integer and sometimes it will be a string
              # convert it to a string for consistency
              b.key.toString()
            )

            buckets = buckets.filter( (b) ->
              filtered_ids.indexOf(b.key.match(/\d+/)[0]) != -1
            )

          if searchString
            # merge results
            newState.filterables[fieldName] ?= [] # aggs[fieldName].buckets
            newState.filterables[fieldName] = newState.filterables[fieldName].concat(buckets)
          else
            newState.filterables[fieldName] = buckets
          newState["waitingFor_#{_fieldName}"] = false
        else
          newState = {
            counts: {
              learners: data.hits.total
              students: aggs.count_students.value
              classes:  aggs.count_classes.value
              teachers:  aggs.count_teachers.value
              runnables: aggs.count_runnables.value
            }
          }
        @setState newState
        return data
    )(_fieldName)

    if queryCache[cacheKey]?.then    # already made a Promise that is still pending
      queryCache[cacheKey].then handleResponse      # chain a new Then
    else if queryCache[cacheKey]    # have data that has already returned
      handleResponse queryCache[cacheKey]           # use it directly
    else
      queryCache[cacheKey] = jQuery.ajax({          # make req and add new Promise to cache
        url: "/api/v1/report_learners_es",
        type: 'GET',
        data: params
      }).then handleResponse

  getQueryParams: ->
    params = {}
    for filter in ["schools", "teachers", "runnables", "permission_forms"]
      if @state[filter]?.length > 0
        params[filter] = @state[filter].map( (v) -> v.value).sort().join(",")
    for filter in ["start_date", "end_date"]
      if @state[filter]?.length > 0 then params[filter] = @state[filter]
    params

  updateFilters: ->
    params = @getQueryParams()

    # update the counts, and the values in all the dropdowns. We have to do
    # them all separately, as each dropdown may require a different query,
    # depending on the other filters. If the queries are the same, however,
    # no additional requests are made over the network
    @query params
    @query params, "schools"
    @query params, "teachers"
    @query params, "runnables"
    @query params, "permission_forms"

  renderTopInfo: ->
    if (Object.keys(@state.counts)).length
      Object.keys(@state.counts).map( (k) => (span {style: {paddingLeft: 12}, key: k},
        (span {style: {fontWeight: 'bold'}}, k)
        (span {style: {paddingLeft: 6}}, @state.counts[k])
      ))
    else
      (i {className: 'wait-icon fa fa-spinner fa-spin'})

  renderInput: (name) ->
    return unless @state.filterables[name]
    agg = @state.filterables[name]

    isLoading = @state["waitingFor_#{name}"]
    placeholder = unless isLoading then "Select ..." else "Loading ..."

    # convert to all strings
    options = agg.map (f) -> if typeof f is "string" then f else f.key

    # rm dupes
    options = options.filter (str, i) -> options.indexOf(str) == i

    # split into values/labels
    options = options.map( (f) ->
      idName = if typeof f is "string" then f.split(/:(.+)/) else f.key.split(/:(.+)/)
      return { value: idName[0], label: idName[1]}
    )

    # rm messed-up ES values
    options = options.filter (o) -> o.value.indexOf("%{") < 0

    (div {style: {marginTop: "6px"}},
      (span {}, title(name))
      (ReactSelect {
        name: name
        options: options
        multi: true
        joinValues: true
        placeholder: placeholder
        isLoading: isLoading
        value: @state[name]
        onInputChange: (value) =>
          if (value.length == 4)
            params = @getQueryParams()
            @query params, name, value
            value
        onChange: (value) =>
          @setState {"#{name}": value}, () =>
            @updateFilters()
      })
    )

  renderDatePicker: (name) ->
    overlayStyle = {
      position: 'absolute',
      background: 'white',
      boxShadow: '0 2px 5px rgba(0, 0, 0, .15)',
    }
    label = if name is "start_date"
      "Earliest date of last run"
    else
      "Latest date of last run"

    (div {span: {marginTop: "6px"}},
      (span {}, label)
      (DayP {
        name: name
        value: @state[name],
        onChange: (value) =>
          @setState {"#{name}": value}, () =>
            @updateFilters()
      })
    )

  renderCheck: (name) ->
    (div {},
      (input {
        name: name
        type: "checkbox"
        style: {margin: "15px 10px 0 0"}
        checked: @state[name]
        onChange: (evt) => @setState {"#{name}": evt.target.checked}
      })
      title(name)
    )

  renderButton: (name) ->
    (input {
      style: {margin: "10px 10px 0 0"}
      type: "submit"
      name: "commit"
      value: name
    })


  renderForm: ->
    (form {url: window.location.pathname, method: "get", id: queryFormID},
      @renderInput 'schools'
      @renderInput 'teachers'
      @renderInput 'runnables'
      @renderInput 'permission_forms'

      @renderDatePicker 'start_date'
      @renderDatePicker 'end_date'

      @renderCheck 'hide_names'

      @renderButton "Usage Report"
      @renderButton "Details Report"
      @renderButton "Arg Block Report"
    )

  render: ->
    (div {},
      (div {},
        (h3 {}, "Your filter matches:")
        @renderTopInfo()
      )
      @renderForm()
    )


window.LogReportButton = React.createClass
  getInitialState: ->
    {
      disabled: false
    }

  render: ->
    (button {onClick: @handleClick, disabled: @state.disabled}, @props.label)

  handleClick: ->
    # Get the signed query JSON first.
    jQuery.ajax(
      type: "GET",
      dataType: "json",
      url: Portal.API_V1.LOGS_QUERY + "?" + jQuery("##{queryFormID}").serialize(),
      success: (response) =>
        # Issue POST request to Log app. We can't use GET, as URL could get too long. Generating a fake
        # form is a way to send non-Ajax POST request and open the target page.
        jQuery(
          '<form action="' + @props.url + '" method="POST">' +
          '<input type="hidden" name="json" value=\'' + JSON.stringify(response.json) + '\'>' +
          '<input type="hidden" name="signature" value="' + response.signature + '">' +
          '</form>'
        ).appendTo('body').submit()
      error: (jqXHR, textStatus, error) =>
        window.alert("Logs query generation failed. Please reload the page and try again.")
        console.error("logs_query request failed")
        @setState(disabled: false)
    )

    @setState(disabled: true)

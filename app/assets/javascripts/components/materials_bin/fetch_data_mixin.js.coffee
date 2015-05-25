# Fetches defined data when component is visible (when @props.visible == true).
# Data is saved under @state[@dataStateName].
# Client class has to define:
#  - .dataUrl property
#  - .dataStateName property (string), name of the state attr which stores downloaded data
# but it can also define:
#  - .requestParams property (hash, argument of jQuery.ajax)
#  - .processData() method that processes raw AJAX response before state is updated
window.MBFetchDataMixin =
  getInitialState: ->
    state = {}
    state[@dataStateName] = null
    state

  componentDidMount: ->
    # Download data only if component is visibile.
    @fetchData() if @props.visible

  componentWillReceiveProps: (nextProps) ->
    # Download data only if component is going to be visibile.
    @fetchData() if nextProps.visible

  fetchData: ->
    # Don't download data if it's been already done.
    return if @state[@dataStateName]?
    params = if @requestParams? then @requestParams() else {}
    jQuery.ajax
      url: @dataUrl
      data: params
      dataType: 'json'
      success: (data) =>
        if @isMounted()
          newState = {}
          # Use @processData method if defined.
          newState[@dataStateName] = if @processData? then @processData(data) else data
          @setState newState

  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

# Fetches remote data when component is visible (when @props.visible == true).
# Data is saved under @state[@dataStateKey].
# Client class has to define:
#  - .dataUrl property (string)
#  - .dataStateKey property (string), name of the state key under which data is saved
# but it can also define:
#  - .requestParams property (hash), argument of jQuery.ajax
#  - .processData() (method), it can process raw AJAX response before state is updated
window.MBFetchDataMixin =
  getInitialState: ->
    state = {}
    state[@dataStateKey] = null
    state

  componentDidMount: ->
    # Download data only if component is visibile.
    @fetchData() if @props.visible

  componentWillReceiveProps: (nextProps) ->
    # Download data only if component is going to be visibile.
    @fetchData() if nextProps.visible

  fetchData: ->
    # Don't download data if it's been already done.
    return if @state[@dataStateKey]?
    params = if @requestParams? then @requestParams() else {}
    jQuery.ajax
      url: @dataUrl
      data: params
      dataType: 'json'
      success: (data) =>
        if @isMounted()
          newState = {}
          # Use @processData method if defined.
          newState[@dataStateKey] = if @processData? then @processData(data) else data
          @setState newState

  archive: (material_id, arhive_url) ->
    # TODO: this uses normal requests instead of JSON
    jQuery.ajax
      url: arhive_url
      success: (data) =>
        newState = @state.collectionsData.map (d) ->
          copy = Object.clone(d)
          copy.materials = d.materials.filter (m) -> m.id != material_id
          copy
        @setState(collectionsData: newState)

  archiveSingle: (material_id, arhive_url) ->
    # TODO: this uses normal requests instead of JSON
    jQuery.ajax
      url: arhive_url
      success: (data) =>
        newState = @state.materials.filter (m) -> m.id != material_id
        @setState(materials: newState)


  getVisibilityClass: ->
    unless @props.visible then 'mb-hidden' else ''

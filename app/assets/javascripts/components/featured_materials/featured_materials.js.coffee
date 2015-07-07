{div} = React.DOM

module.exports = React.createClass
  getInitialState: ->
    materials: []

  componentDidMount: ->
    jQuery.ajax
      url: Portal.API_V1.MATERIALS_FEATURED
      data: @props.queryString
      dataType: 'json'
      success: (data) =>
        @setState materials: data if @isMounted()

  render: ->
    (SMaterialsList {materials: @state.materials})

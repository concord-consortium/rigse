{div} = React.DOM

window.FeaturedMaterialsClass = React.createClass
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

window.FeaturedMaterials = React.createFactory FeaturedMaterialsClass

Portal.renderFeaturedMaterials = (selectorOrElement) ->
  query = window.location.search
  query = query.slice(1) if query[0] == '?'
  React.render FeaturedMaterials(queryString: query), jQuery(selectorOrElement)[0]

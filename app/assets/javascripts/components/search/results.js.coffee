{div, p, span} = React.DOM

window.SearchResultsClass = React.createClass
  generateScrollTo: (type)->
    return (event) ->
      window.scrollTo 0, $("#{type}_bookmark").offsetTop

  renderMessage: ->
    message = for group in @props.results
      link = {url: 'javascript:void(0)', onclick: @generateScrollTo(group.type), text: group.header, className: ''}
      (span {},
        group.pagination.total_items, ' ', (SGenericLink {link: link})
      )
    if @props.results.length > 1
      for i in [(@props.results.length - 1)..1] by -1
        message.splice i, 0, (span {}, ', ')
    message

  renderAllResults: ->
    for group in @props.results
      (SearchResultGroup {group: group, key: group.type})

  renderSearchTerm: ->
    if jQuery('#search_term').val().length > 0
      " search term \"#{jQuery('#search_term').val()}\" and"
    else
      ''

  render: ->
    (div {id: 'offering_list'},
      (p {style: {fontWeight: 'bold'}},
        @renderMessage(), ' matching ', @renderSearchTerm(), ' slected criteria'
      )
      (div {className: 'results_container'},
        @renderAllResults()
      )
    )

window.SearchResults = React.createFactory SearchResultsClass

window.renderSearchResults = (results, dest) ->
  React.render SearchResults(results), jQuery(dest)[0]

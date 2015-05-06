SearchResults = React.createClass
  generateScrollTo: (type)->
    return (event)->
      window.scrollTo(0,$("#{type}_bookmark").offsetTop)

  render: ->
    message =  @props.results.map (group)=>
      link = {url: 'javascript:void(0)', onclick: @generateScrollTo(group.type), text: group.header, className: ''}
      return `(
        <span>
          {group.pagination.total_items} <GenericLink link={link} />
        </span>
      )`
    if @props.results.length > 1
      for i in [(@props.results.length-1)..1] by -1
        message.splice(i, 0, `<span>, </span>`)
    all_results = @props.results.map (group)-> `<SearchResultGroup group={group} key={group.type} />`
    if jQuery('#search_term').val().length > 0
      search_term = " search term \"#{jQuery('#search_term').val()}\" and"
    else
      search_term = ''
    return `(
      <div id='offering_list'>
        <p style={{fontWeight: 'bold'}}>
          {message} matching{search_term} selected criteria
        </p>
        <div className={'results_container'}>
          {all_results}
        </div>
      </div>
    )`

window.SearchResults = SearchResults

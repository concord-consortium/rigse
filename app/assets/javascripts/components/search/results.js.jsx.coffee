SearchResults = React.createClass
  scrollTo: (event)->
    console.log(event)
    window.scrollTo(0,$("activities_bookmark").offsetTop)

  render: ->
    message =  (@props.results.map (group)-> `<span>{group.pagination.total_items} <GenericLink link={{url: 'javascript:void(0)', onclick: this.scrollTo, text: group.header, className: ''}} /></span>`)
    if @props.results.length > 1
      for i in [(@props.results.length-1)..1] by -1
        message.splice(i, 0, `<span>, </span>`)
    all_results = @props.results.map (group)-> `<SearchResultGroup group={group} key={group.type} />`
    return `(
      <div id='offering_list'>
        <p style={{fontWeight: 'bold'}}>
          {message} matching selected criteria
        </p>
        <div className={'results_container'}>
          {all_results}
        </div>
      </div>
    )`

window.SearchResults = SearchResults

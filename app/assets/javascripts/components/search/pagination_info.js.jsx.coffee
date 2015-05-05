PaginationInfo = React.createClass
  render: ->
    info = @props.info
    return `(
      <span>
        Displaying {info.start_item} - {info.end_item} of {info.total_items} total
      </span>
    )`

window.PaginationInfo = PaginationInfo

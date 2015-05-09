{span, b} = React.DOM

window.SPaginationInfoClass = React.createClass
  render: ->
    info = @props.info
    if info.total_items <= info.per_page
      (span {}, 'Displaying ', (b {}, "all #{info.total_items}"))
    else
      (span {}, 'Displaying ', (b {}, "#{info.start_item} - #{info.end_item}"), ' of ', (b {}, "#{info.total_items}"))

window.SPaginationInfo = React.createFactory SPaginationInfoClass

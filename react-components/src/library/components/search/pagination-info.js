import React from 'react'

export default class SPaginationInfo extends React.Component {
  render () {
    const { info } = this.props
    if (info.total_items <= info.per_page) {
      return <span>Displaying <b>all {info.total_items}</b></span>
    } else {
      return <span>Displaying <b>{info.start_item} - {info.end_item}</b> of <b>{info.total_items}</b></span>
    }
  }
}
